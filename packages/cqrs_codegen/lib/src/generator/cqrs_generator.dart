import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations/cqrs_annotations.dart';
import '../model/handler_info.dart';
import '../parser/handler_parser.dart';

/// Generator that creates [HandlerRegistry] registration extensions.
class CqrsGenerator extends Generator {
  const CqrsGenerator({this.parser = const HandlerParser()});

  final HandlerParser parser;

  static const _initChecker = TypeChecker.typeNamed(CqrsInit);

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final annotated = library.annotatedWith(_initChecker);
    if (annotated.isEmpty) return null;

    final annotation = annotated.first.annotation;
    final includeDefaults =
        annotation.peek('includeDefaultFactories')?.boolValue ?? true;

    // Collect all class elements accessible from this library and its parts/exports
    final handlers = <HandlerInfo>[];
    final visitedClasses = <String>{};

    void inspectClass(ClassElement classElement) {
      final name = classElement.name;
      if (name != null && !visitedClasses.contains(name)) {
        visitedClasses.add(name);
        final info = parser.parseClass(classElement);
        if (info != null) {
          handlers.add(info);
        }
      }
    }

    // Inspect classes in the current library
    for (final c in library.classes) {
      inspectClass(c);
    }

    // Inspect classes from exported libraries
    final libElement = library.element;
    for (final exported in libElement.exportedLibraries) {
      if (exported.isInSdk) continue;
      for (final c in exported.classes) {
        inspectClass(c);
      }
    }

    if (handlers.isEmpty) {
      return '''
// No CQRS handlers found in scope.
extension AutoRegisterCqrs on HandlerRegistry {
  void registerGeneratedHandlers() {}
}
''';
    }

    final buffer = StringBuffer();
    buffer.writeln('/// Generated registration helper for discovered CQRS handlers.');
    buffer.writeln('extension AutoRegisterCqrs on HandlerRegistry {');
    buffer.writeln('  void registerGeneratedHandlers({');

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
        case HandlerKind.streamQuery:
          buffer.writeln(
            '    registerStreamQuery<${handler.messageTypeName}, ${handler.resultTypeName}>(${handler.paramName});',
          );
        case HandlerKind.event:
          buffer.writeln(
            '    registerEvent<${handler.messageTypeName}>(${handler.paramName});',
          );
      }
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }
}
