import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// The kind of CQRS handler.
enum HandlerKind {
  command,
  query,
  event,
}

/// Metadata extracted about a CQRS handler.
class HandlerInfo {
  HandlerInfo({
    required this.className,
    required this.kind,
    required this.messageTypeName,
    required this.hasDefaultConstructor,
    this.resultTypeName,
    this.classElement,
    this.messageType,
    this.resultType,
  });

  /// The name of the handler class.
  final String className;

  /// The kind of handler.
  final HandlerKind kind;

  /// The type name of the command, query, or event.
  final String messageTypeName;

  /// The type name of the result (for command/query).
  final String? resultTypeName;

  /// Whether the handler class has an unnamed constructor with no required arguments.
  final bool hasDefaultConstructor;

  /// The underlying [ClassElement] of the handler.
  final ClassElement? classElement;

  /// The underlying [DartType] of the message (Command/Query/Event).
  final DartType? messageType;

  /// The underlying [DartType] of the result (for Command/Query).
  final DartType? resultType;

  /// Parameter name for factory function (e.g. `createUserCommandHandler`).
  String get paramName {
    if (className.isEmpty) return 'handler';
    return className[0].toLowerCase() + className.substring(1);
  }
}
