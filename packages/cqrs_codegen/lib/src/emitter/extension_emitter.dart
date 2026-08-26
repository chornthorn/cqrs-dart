import '../model/handler_info.dart';
import '../model/import_alias_registry.dart';

/// Emits `HandlerRegistry` extension methods for registering CQRS handlers.
class ExtensionEmitter {
  const ExtensionEmitter();

  /// Writes the `AutoRegister...Cqrs` extension on `HandlerRegistry` to [buffer].
  void writeExtension(
    StringBuffer buffer, {
    required String extensionName,
    required String methodName,
    required List<HandlerInfo> handlers,
    required bool includeDefaults,
    required bool generateInjectable,
    required ImportAliasRegistry aliasRegistry,
  }) {
    if (handlers.isEmpty) {
      buffer.writeln('// No CQRS handlers found in scope.');
      buffer.writeln('extension $extensionName on _i1.HandlerRegistry {');
      buffer.writeln('  void $methodName() {}');
      buffer.writeln('}');
      return;
    }

    buffer.writeln(
      '/// Generated registration helper for discovered CQRS handlers ($extensionName).',
    );
    buffer.writeln('extension $extensionName on _i1.HandlerRegistry {');
    buffer.writeln('  void $methodName({');

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

    buffer.writeln('  }) {');

    for (final handler in handlers) {
      final msgTypeStr = aliasRegistry.formatType(handler.messageType);
      final resTypeStr = handler.resultType != null
          ? aliasRegistry.formatType(handler.resultType)
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

    // Emit service locator registration helper if generateInjectable is enabled
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
        final handlerTypeStr =
            aliasRegistry.formatType(handler.classElement?.thisType);
        buffer.writeln(
          '      ${handler.paramName}: () => locator<$handlerTypeStr>(),',
        );
      }
      buffer.writeln('    );');
      buffer.writeln('  }');
    }

    buffer.writeln('}');
  }
}
