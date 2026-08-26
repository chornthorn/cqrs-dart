import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../model/handler_info.dart';

/// Parses class elements into [HandlerInfo] metadata.
class HandlerParser {
  const HandlerParser();

  /// Inspects [classElement] and returns [HandlerInfo] if it is a CQRS handler.
  HandlerInfo? parseClass(ClassElement classElement) {
    if (classElement.isAbstract) return null;

    final className = classElement.name;
    if (className == null || className.isEmpty) return null;

    // Check if class has an unnamed constructor with no required parameters
    var hasDefaultConstructor = false;
    for (final ctor in classElement.constructors) {
      final ctorName = ctor.name;
      if (ctorName == null || ctorName.isEmpty || ctorName == 'new' || ctorName == className) {
        if (ctor.formalParameters.every((p) => !p.isRequired)) {
          hasDefaultConstructor = true;
          break;
        }
      }
    }

    for (final supertype in classElement.allSupertypes) {
      final name = supertype.element.name;

      if (name == 'CommandHandler' && supertype.typeArguments.length >= 2) {
        final messageType = supertype.typeArguments[0];
        final resultType = supertype.typeArguments[1];
        return HandlerInfo(
          className: className,
          kind: HandlerKind.command,
          messageTypeName: _formatType(messageType),
          resultTypeName: _formatType(resultType),
          hasDefaultConstructor: hasDefaultConstructor,
          classElement: classElement,
          messageType: messageType,
          resultType: resultType,
        );
      }

      if (name == 'QueryHandler' && supertype.typeArguments.length >= 2) {
        final messageType = supertype.typeArguments[0];
        final resultType = supertype.typeArguments[1];
        return HandlerInfo(
          className: className,
          kind: HandlerKind.query,
          messageTypeName: _formatType(messageType),
          resultTypeName: _formatType(resultType),
          hasDefaultConstructor: hasDefaultConstructor,
          classElement: classElement,
          messageType: messageType,
          resultType: resultType,
        );
      }

      if (name == 'EventHandler' && supertype.typeArguments.isNotEmpty) {
        final messageType = supertype.typeArguments[0];
        return HandlerInfo(
          className: className,
          kind: HandlerKind.event,
          messageTypeName: _formatType(messageType),
          hasDefaultConstructor: hasDefaultConstructor,
          classElement: classElement,
          messageType: messageType,
        );
      }
    }

    return null;
  }

  String _formatType(DartType type) {
    return type.getDisplayString();
  }
}
