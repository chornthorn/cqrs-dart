import '../model/handler_info.dart';
import '../model/import_alias_registry.dart';
import '../model/module_info.dart';

/// Emits `CqrsPackageModule` subclasses for feature micro-packages and compositor root modules.
class ModuleClassEmitter {
  const ModuleClassEmitter();

  /// Writes a `CqrsPackageModule` subclass to [buffer].
  void writeModuleClass(
    StringBuffer buffer, {
    required String moduleClassName,
    required String methodName,
    required List<HandlerInfo> handlers,
    required List<DiscoveredModule> subModules,
    required bool includeDefaults,
    required bool generateInjectable,
    required ImportAliasRegistry aliasRegistry,
  }) {
    if (handlers.isEmpty && subModules.isEmpty) {
      _writeEmptyModuleClass(
        buffer,
        moduleClassName: moduleClassName,
        generateInjectable: generateInjectable,
      );
      return;
    }

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
      buffer.writeln(
        '///   ${paramName(s.moduleClassName)}: ${s.moduleClassName}(...),',
      );
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
      final alias = aliasRegistry.aliases[s.packageUri] ?? '_i1';
      buffer.writeln(
        '    required $alias.${s.moduleClassName} ${paramName(s.moduleClassName)},',
      );
    }
    for (final handler in handlers) {
      final handlerTypeStr =
          aliasRegistry.formatType(handler.classElement?.thisType);
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
        final alias = aliasRegistry.aliases[s.packageUri] ?? '_i1';
        buffer.writeln(
          '      ${paramName(s.moduleClassName)}: $alias.${s.moduleClassName}.fromLocator(locator),',
        );
      }
      for (final handler in handlers) {
        final handlerTypeStr =
            aliasRegistry.formatType(handler.classElement?.thisType);
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
      final alias = aliasRegistry.aliases[s.packageUri] ?? '_i1';
      buffer.writeln(
        '  final $alias.${s.moduleClassName} _${paramName(s.moduleClassName)};',
      );
    }
    for (final handler in handlers) {
      final handlerTypeStr =
          aliasRegistry.formatType(handler.classElement?.thisType);
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

  void _writeEmptyModuleClass(
    StringBuffer buffer, {
    required String moduleClassName,
    required bool generateInjectable,
  }) {
    buffer.writeln(
      '/// Generated [CqrsPackageModule] with no registered handlers.',
    );
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
}
