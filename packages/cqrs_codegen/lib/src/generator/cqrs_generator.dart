import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations/cqrs_annotations.dart';
import '../model/handler_info.dart';
import 'library_scanner.dart';

/// Source generator that scans for CQRS handlers and produces type-safe
/// `HandlerRegistry` extension methods and/or `CqrsPackageModule` subclasses.
class CqrsGenerator extends Generator {
  const CqrsGenerator({this.scanner = const LibraryScanner()});

  final LibraryScanner scanner;

  static const _anyChecker = TypeChecker.any([
    TypeChecker.typeNamed(CqrsInit),
    TypeChecker.typeNamed(CqrsMicroPackage),
  ]);

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final annotated = library.annotatedWith(_anyChecker);
    if (annotated.isEmpty) return null;

    final annotationTypeName =
        annotated.first.annotation.objectValue.type?.element?.name ?? '';
    final bool isMicroPackage = annotationTypeName == 'CqrsMicroPackage';

    // If this is an individual micro-package, skip generation when root @CqrsInit has disabled micro-packages
    if (isMicroPackage) {
      final isGloballyEnabled =
          await scanner.isMicroPackageGloballyEnabled(buildStep);
      if (!isGloballyEnabled) {
        return null;
      }
    }

    final annotation = annotated.first.annotation;
    final moduleName = annotation.peek('moduleName')?.stringValue;
    final customMethodName = annotation.peek('methodName')?.stringValue;
    final customExtensionName = annotation.peek('extensionName')?.stringValue;
    final customModuleClassName = annotation.peek('moduleClassName')?.stringValue;
    final includeDefaults =
        annotation.peek('includeDefaultFactories')?.boolValue ?? true;
    bool useMicroPackage =
        annotation.peek('useMicroPackage')?.boolValue ?? isMicroPackage;
    bool generateInjectable =
        annotation.peek('generateInjectable')?.boolValue ?? false;

    // Read the list of CqrsPackageModule subclass types provided by the user.
    final moduleTypeNames = <String>[];
    final modulesReader = annotation.peek('modules');
    if (modulesReader?.listValue != null) {
      for (final obj in modulesReader!.listValue) {
        final name = obj.toTypeValue()?.getDisplayString().replaceAll('?', '') ??
            obj.toTypeValue()?.element?.name;
        if (name != null && name != 'dynamic' && name != 'InvalidType') {
          moduleTypeNames.add(name);
        }
      }
    }

    // Fallback to AST inspection if constant evaluation is not available
    if (moduleTypeNames.isEmpty || !useMicroPackage) {
      try {
        final session = library.element.session;
        final parsedLib = session.getParsedLibraryByElement(library.element);
        if (parsedLib is ParsedLibraryResult) {
          for (final unit in parsedLib.units) {
            for (final decl in unit.unit.declarations) {
              for (final ann in decl.metadata) {
                final annName = ann.name.name;
                if (annName == 'CqrsInit' || annName == 'CqrsMicroPackage') {
                  final args = ann.arguments?.arguments;
                  if (args != null) {
                    for (final arg in args) {
                      if (arg is NamedArgument) {
                        if (arg.name.lexeme == 'useMicroPackage') {
                          final expr = arg.argumentExpression;
                          if (expr is BooleanLiteral) {
                            useMicroPackage = expr.value;
                          }
                        } else if (arg.name.lexeme == 'modules') {
                          final expr = arg.argumentExpression;
                          if (expr is ListLiteral) {
                            for (final elem in expr.elements) {
                              final src = elem.toSource().trim();
                              if (src.isNotEmpty) {
                                moduleTypeNames.add(src);
                              }
                            }
                          }
                        } else if (arg.name.lexeme == 'generateInjectable') {
                          final expr = arg.argumentExpression;
                          if (expr is BooleanLiteral) {
                            generateInjectable = expr.value;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // If this is an individual micro-package, inherit generateInjectable if enabled in root init
    if (isMicroPackage && !generateInjectable) {
      generateInjectable = await scanner.isInjectableGloballyEnabled(buildStep);
    }

    // Resolve naming for micro-packages or standard modules
    String extensionName;
    if (customExtensionName != null && customExtensionName.isNotEmpty) {
      extensionName = customExtensionName;
    } else if (moduleName != null && moduleName.isNotEmpty) {
      extensionName = 'AutoRegister${_capitalize(moduleName)}Cqrs';
    } else {
      extensionName = 'AutoRegisterCqrs';
    }

    String methodName;
    if (customMethodName != null && customMethodName.isNotEmpty) {
      methodName = customMethodName;
    } else if (moduleName != null && moduleName.isNotEmpty) {
      methodName = 'register${_capitalize(moduleName)}Handlers';
    } else {
      methodName = 'registerGeneratedHandlers';
    }

    String moduleClassName;
    if (customModuleClassName != null && customModuleClassName.isNotEmpty) {
      moduleClassName = customModuleClassName;
    } else if (moduleName != null && moduleName.isNotEmpty) {
      moduleClassName = '${_capitalize(moduleName)}CqrsModule';
    } else {
      moduleClassName = 'GeneratedCqrsModule';
    }

    final bool isRootCompositor = !isMicroPackage && useMicroPackage;

    // Scan directory for handlers or sub-modules, respecting micro-package boundaries
    final scanResult = await scanner.scanDirectory(
      buildStep: buildStep,
      targetAsset: buildStep.inputId,
      isMicroPackage: isMicroPackage,
      useMicroPackage: useMicroPackage,
    );

    final handlers = scanResult.handlers;
    final discoveredModuleClasses = <String>[
      for (final sub in scanResult.subModules) sub.moduleClassName,
    ];

    // Prioritize user's manual module list if specified
    final effectiveModuleClasses =
        moduleTypeNames.isNotEmpty ? moduleTypeNames : discoveredModuleClasses;

    final bool shouldEmitModuleClass =
        useMicroPackage && (handlers.isNotEmpty || effectiveModuleClasses.isNotEmpty);

    // Build alias mappings (Injectable-style)
    final cqrsUri = Uri.parse('package:cqrs/cqrs.dart');
    final importAliases = <Uri, String>{
      cqrsUri: '_i1',
    };

    var aliasIndex = 2;
    if (isRootCompositor) {
      for (final sub in scanResult.subModules) {
        if (effectiveModuleClasses.contains(sub.moduleClassName)) {
          if (!importAliases.containsKey(sub.packageUri)) {
            importAliases[sub.packageUri] = '_i$aliasIndex';
            aliasIndex++;
          }
        }
      }
    } else {
      for (final uri in scanResult.typeUris) {
        if (!importAliases.containsKey(uri)) {
          importAliases[uri] = '_i$aliasIndex';
          aliasIndex++;
        }
      }
    }

    final buffer = StringBuffer();
    buffer.writeln(
      '// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals',
    );
    buffer.writeln();

    // 1. Emit aliased absolute imports
    for (final entry in importAliases.entries) {
      buffer.writeln("import '${entry.key}' as ${entry.value};");
    }
    buffer.writeln();

    // 2. Emit HandlerRegistry extension method (if handlers exist)
    if (handlers.isNotEmpty) {
      buffer.writeln(
        '/// Generated registration helper for discovered CQRS handlers ($extensionName).',
      );
      buffer.writeln('extension $extensionName on _i1.HandlerRegistry {');
      buffer.writeln('  void $methodName({');

      for (final handler in handlers) {
        final handlerTypeStr =
            scanner.formatTypeWithAlias(handler.classElement?.thisType, importAliases);
        final paramType = '$handlerTypeStr Function()';
        if (handler.hasDefaultConstructor && includeDefaults) {
          buffer.writeln(
            '    $paramType ${handler.paramName} = $handlerTypeStr.new,',
          );
        } else {
          buffer.writeln('    required $paramType ${handler.paramName},');
        }
      }

      buffer.writeln('  }) {');

      for (final handler in handlers) {
        final msgTypeStr =
            scanner.formatTypeWithAlias(handler.messageType, importAliases);
        final resTypeStr = handler.resultType != null
            ? scanner.formatTypeWithAlias(handler.resultType, importAliases)
            : null;

        switch (handler.kind) {
          case HandlerKind.command:
            buffer.writeln(
              '    registerCommand<$msgTypeStr, $resTypeStr>(${handler.paramName});',
            );
          case HandlerKind.query:
            buffer.writeln(
              '    registerQuery<$msgTypeStr, $resTypeStr>(${handler.paramName});',
            );
          case HandlerKind.event:
            buffer.writeln(
              '    registerEvent<$msgTypeStr>(${handler.paramName});',
            );
        }
      }

      buffer.writeln('  }');

      // If generateInjectable is enabled, also emit extension helper for service locators
      if (generateInjectable) {
        buffer.writeln();
        buffer.writeln(
          '  /// Registers all handlers by resolving them from a service locator.',
        );
        buffer.writeln(
          '  void ${methodName}FromLocator(T Function<T extends Object>() locator) {',
        );
        buffer.writeln('    $methodName(');
        for (final handler in handlers) {
          final handlerTypeStr = scanner.formatTypeWithAlias(
            handler.classElement?.thisType,
            importAliases,
          );
          buffer.writeln(
            '      ${handler.paramName}: () => locator<$handlerTypeStr>(),',
          );
        }
        buffer.writeln('    );');
        buffer.writeln('  }');
      }

      buffer.writeln('}');
    } else if (!shouldEmitModuleClass) {
      buffer.writeln('// No CQRS handlers found in scope.');
      buffer.writeln('extension $extensionName on _i1.HandlerRegistry {');
      buffer.writeln('  void $methodName() {}');
      buffer.writeln('}');
    }

    // 3. Emit CqrsPackageModule subclass if useMicroPackage is true
    if (useMicroPackage) {
      buffer.writeln();
      if (handlers.isEmpty && effectiveModuleClasses.isEmpty) {
        _writeEmptyModuleClass(
          buffer,
          moduleClassName,
          methodName,
          generateInjectable: generateInjectable,
        );
      } else {
        _writeUnifiedModuleClass(
          buffer,
          moduleClassName: moduleClassName,
          methodName: methodName,
          handlers: handlers,
          subModules: scanResult.subModules
              .where((s) => effectiveModuleClasses.contains(s.moduleClassName))
              .toList(),
          includeDefaults: includeDefaults,
          importAliases: importAliases,
          generateInjectable: generateInjectable,
        );
      }
    }

    return buffer.toString();
  }

  /// Emits an empty [CqrsPackageModule] subclass when no handlers are found.
  void _writeEmptyModuleClass(
    StringBuffer buffer,
    String moduleClassName,
    String methodName, {
    required bool generateInjectable,
  }) {
    buffer.writeln('/// Generated [CqrsPackageModule] with no registered handlers.');
    buffer.writeln('class $moduleClassName extends _i1.CqrsPackageModule {');
    buffer.writeln('  const $moduleClassName() : super();');
    if (generateInjectable) {
      buffer.writeln();
      buffer.writeln(
        '  /// Factory constructor that resolves all dependencies from a service locator.',
      );
      buffer.writeln(
        '  factory $moduleClassName.fromLocator(T Function<T extends Object>() locator) => const $moduleClassName();',
      );
    }
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  void register(_i1.HandlerRegistry registry) {}');
    buffer.writeln('}');
  }

  /// Emits a unified [CqrsPackageModule] subclass that holds direct handler factories
  /// and/or nested sub-module instances.
  void _writeUnifiedModuleClass(
    StringBuffer buffer, {
    required String moduleClassName,
    required String methodName,
    required List<HandlerInfo> handlers,
    required List<DiscoveredModule> subModules,
    required bool includeDefaults,
    required Map<Uri, String> importAliases,
    required bool generateInjectable,
  }) {
    String paramName(String typeName) =>
        typeName[0].toLowerCase() + typeName.substring(1);

    buffer.writeln(
      '/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.',
    );
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// registry.registerModule($moduleClassName(');
    if (subModules.isNotEmpty) {
      final s = subModules.first;
      buffer.writeln('///   ${paramName(s.moduleClassName)}: ${s.moduleClassName}(...),');
    } else if (handlers.isNotEmpty) {
      final h = handlers.first;
      buffer.writeln('///   ${h.paramName}: ${h.className}.new,');
    }
    buffer.writeln('/// ));');
    buffer.writeln('/// ```');
    buffer.writeln('class $moduleClassName extends _i1.CqrsPackageModule {');

    // Constructor
    buffer.writeln('  const $moduleClassName({');
    for (final s in subModules) {
      final alias = importAliases[s.packageUri] ?? '_i1';
      buffer.writeln(
        '    required $alias.${s.moduleClassName} ${paramName(s.moduleClassName)},',
      );
    }
    for (final handler in handlers) {
      final handlerTypeStr =
          scanner.formatTypeWithAlias(handler.classElement?.thisType, importAliases);
      final paramType = '$handlerTypeStr Function()';
      if (handler.hasDefaultConstructor && includeDefaults) {
        buffer.writeln(
          '    $paramType ${handler.paramName} = $handlerTypeStr.new,',
        );
      } else {
        buffer.writeln('    required $paramType ${handler.paramName},');
      }
    }
    buffer.writeln('  }) :');

    // Initializer list
    final inits = <String>[
      for (final s in subModules)
        '_${paramName(s.moduleClassName)} = ${paramName(s.moduleClassName)}',
      for (final h in handlers) '_${h.paramName} = ${h.paramName}',
    ];
    buffer.writeln('        ${inits.join(',\n        ')},');
    buffer.writeln('        super();');

    // fromLocator constructor when generateInjectable is true
    if (generateInjectable) {
      buffer.writeln();
      buffer.writeln(
        '  /// Factory constructor that resolves all handlers from a dependency locator (e.g. GetIt.instance.get).',
      );
      buffer.writeln(
        '  factory $moduleClassName.fromLocator(T Function<T extends Object>() locator) {',
      );
      buffer.writeln('    return $moduleClassName(');
      for (final s in subModules) {
        final alias = importAliases[s.packageUri] ?? '_i1';
        buffer.writeln(
          '      ${paramName(s.moduleClassName)}: $alias.${s.moduleClassName}.fromLocator(locator),',
        );
      }
      for (final handler in handlers) {
        final handlerTypeStr = scanner.formatTypeWithAlias(
          handler.classElement?.thisType,
          importAliases,
        );
        buffer.writeln(
          '      ${handler.paramName}: () => locator<$handlerTypeStr>(),',
        );
      }
      buffer.writeln('    );');
      buffer.writeln('  }');
    }

    buffer.writeln();

    // Private fields
    for (final s in subModules) {
      final alias = importAliases[s.packageUri] ?? '_i1';
      buffer.writeln('  final $alias.${s.moduleClassName} _${paramName(s.moduleClassName)};');
    }
    for (final handler in handlers) {
      final handlerTypeStr =
          scanner.formatTypeWithAlias(handler.classElement?.thisType, importAliases);
      buffer.writeln(
        '  final $handlerTypeStr Function() _${handler.paramName};',
      );
    }
    buffer.writeln();

    // register() override
    buffer.writeln('  @override');
    buffer.writeln('  void register(_i1.HandlerRegistry registry) {');
    if (handlers.isNotEmpty) {
      buffer.writeln('    registry.$methodName(');
      for (final handler in handlers) {
        buffer.writeln('      ${handler.paramName}: _${handler.paramName},');
      }
      buffer.writeln('    );');
    }
    if (subModules.isNotEmpty) {
      buffer.writeln('    registry.registerModules([');
      for (final s in subModules) {
        buffer.writeln('      _${paramName(s.moduleClassName)},');
      }
      buffer.writeln('    ]);');
    }
    buffer.writeln('  }');
    buffer.writeln('}');
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
