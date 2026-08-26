import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import '../annotations/cqrs_annotations.dart';
import '../model/handler_info.dart';
import '../parser/handler_parser.dart';
import 'library_scanner.dart';

/// Generator that creates standalone `.cqrs.dart` files with auto-imports,
/// registration extensions, and `CqrsPackageModule` subclasses.
class CqrsGenerator extends Generator {
  const CqrsGenerator({
    this.parser = const HandlerParser(),
    this.scanner = const LibraryScanner(),
  });

  final HandlerParser parser;
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

    final annotation = annotated.first.annotation;
    final moduleName = annotation.peek('moduleName')?.stringValue;
    final customMethodName = annotation.peek('methodName')?.stringValue;
    final customExtensionName = annotation.peek('extensionName')?.stringValue;
    final customModuleClassName = annotation.peek('moduleClassName')?.stringValue;
    final includeDefaults =
        annotation.peek('includeDefaultFactories')?.boolValue ?? true;
    bool useMicroPackage =
        annotation.peek('useMicroPackage')?.boolValue ?? isMicroPackage;

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
      isRootCompositor: isRootCompositor,
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

    final buffer = StringBuffer();

    // 1. Emit top-level imports for standalone file
    buffer.writeln("import 'package:cqrs/cqrs.dart';");
    for (final importUri in scanResult.handlerImportUris) {
      buffer.writeln("import '$importUri';");
    }

    if (isRootCompositor) {
      final targetDirPath = p.dirname(buildStep.inputId.path);
      for (final sub in scanResult.subModules) {
        if (effectiveModuleClasses.contains(sub.moduleClassName)) {
          final relPath = p
              .relative(sub.assetId.path, from: targetDirPath)
              .replaceAll(r'\', '/');
          buffer.writeln("import '$relPath';");
        }
      }
    }

    buffer.writeln();

    // 2. Emit HandlerRegistry extension if direct handlers exist
    if (handlers.isNotEmpty) {
      buffer.writeln(
        '/// Generated registration helper for discovered CQRS handlers ($extensionName).',
      );
      buffer.writeln('extension $extensionName on HandlerRegistry {');
      buffer.writeln('  void $methodName({');

      for (final handler in handlers) {
        final paramType = '${handler.className} Function()';
        if (handler.hasDefaultConstructor && includeDefaults) {
          buffer.writeln('    $paramType ${handler.paramName} = ${handler.className}.new,');
        } else {
          buffer.writeln('    required $paramType ${handler.paramName},');
        }
      }

      buffer.writeln('  }) {');

      for (final handler in handlers) {
        switch (handler.kind) {
          case HandlerKind.command:
            buffer.writeln(
              '    registerCommand<${handler.messageTypeName}, ${handler.resultTypeName}>(${handler.paramName});',
            );
          case HandlerKind.query:
            buffer.writeln(
              '    registerQuery<${handler.messageTypeName}, ${handler.resultTypeName}>(${handler.paramName});',
            );
          case HandlerKind.event:
            buffer.writeln(
              '    registerEvent<${handler.messageTypeName}>(${handler.paramName});',
            );
        }
      }

      buffer.writeln('  }');
      buffer.writeln('}');
    } else if (!shouldEmitModuleClass) {
      buffer.writeln('// No CQRS handlers found in scope.');
      buffer.writeln('extension $extensionName on HandlerRegistry {');
      buffer.writeln('  void $methodName() {}');
      buffer.writeln('}');
    }

    // 3. Emit CqrsPackageModule subclass if useMicroPackage is true
    if (useMicroPackage) {
      buffer.writeln(
        '// ignore_for_file: prefer_initializing_formals',
      );
      buffer.writeln();
      if (handlers.isEmpty && effectiveModuleClasses.isEmpty) {
        _writeEmptyModuleClass(buffer, moduleClassName, methodName);
      } else {
        _writeUnifiedModuleClass(
          buffer,
          moduleClassName: moduleClassName,
          methodName: methodName,
          handlers: handlers,
          subModuleTypeNames: effectiveModuleClasses,
          includeDefaults: includeDefaults,
        );
      }
    }

    return buffer.toString();
  }

  /// Emits an empty [CqrsPackageModule] subclass when no handlers are found.
  void _writeEmptyModuleClass(
    StringBuffer buffer,
    String moduleClassName,
    String methodName,
  ) {
    buffer.writeln('/// Generated [CqrsPackageModule] with no registered handlers.');
    buffer.writeln('class $moduleClassName extends CqrsPackageModule {');
    buffer.writeln('  const $moduleClassName() : super();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  void register(HandlerRegistry registry) {}');
    buffer.writeln('}');
  }

  /// Emits a unified [CqrsPackageModule] subclass that holds direct handler factories
  /// and/or nested sub-module instances.
  void _writeUnifiedModuleClass(
    StringBuffer buffer, {
    required String moduleClassName,
    required String methodName,
    required List<HandlerInfo> handlers,
    required List<String> subModuleTypeNames,
    required bool includeDefaults,
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
    for (final t in subModuleTypeNames) {
      buffer.writeln('///   ${paramName(t)}: $t(...),');
    }
    final requiredHandlers =
        handlers.where((h) => !h.hasDefaultConstructor || !includeDefaults);
    for (final h in requiredHandlers) {
      buffer.writeln('///   ${h.paramName}: ${h.className}.new,');
    }
    buffer.writeln('/// ));');
    buffer.writeln('/// ```');
    buffer.writeln('class $moduleClassName extends CqrsPackageModule {');

    // Constructor
    buffer.writeln('  const $moduleClassName({');
    for (final t in subModuleTypeNames) {
      buffer.writeln('    required $t ${paramName(t)},');
    }
    for (final handler in handlers) {
      final paramType = '${handler.className} Function()';
      if (handler.hasDefaultConstructor && includeDefaults) {
        buffer.writeln(
          '    $paramType ${handler.paramName} = ${handler.className}.new,',
        );
      } else {
        buffer.writeln('    required $paramType ${handler.paramName},');
      }
    }
    buffer.writeln('  }) :');

    // Initializer list
    final inits = <String>[
      for (final t in subModuleTypeNames) '_${paramName(t)} = ${paramName(t)}',
      for (final h in handlers) '_${h.paramName} = ${h.paramName}',
    ];
    buffer.writeln('        ${inits.join(',\n        ')},');
    buffer.writeln('        super();');
    buffer.writeln();

    // Private fields
    for (final t in subModuleTypeNames) {
      buffer.writeln('  final $t _${paramName(t)};');
    }
    for (final handler in handlers) {
      buffer.writeln(
        '  final ${handler.className} Function() _${handler.paramName};',
      );
    }
    buffer.writeln();

    // register() override
    buffer.writeln('  @override');
    buffer.writeln('  void register(HandlerRegistry registry) {');
    if (handlers.isNotEmpty) {
      buffer.writeln('    registry.$methodName(');
      for (final handler in handlers) {
        buffer.writeln('      ${handler.paramName}: _${handler.paramName},');
      }
      buffer.writeln('    );');
    }
    if (subModuleTypeNames.isNotEmpty) {
      buffer.writeln('    registry.registerModules([');
      for (final t in subModuleTypeNames) {
        buffer.writeln('      _${paramName(t)},');
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
