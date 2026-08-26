/// The kind of CQRS handler.
enum HandlerKind {
  command,
  query,
  streamQuery,
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
  });

  /// The name of the handler class.
  final String className;

  /// The kind of handler.
  final HandlerKind kind;

  /// The type name of the command, query, or event.
  final String messageTypeName;

  /// The type name of the result (for command/query/streamQuery).
  final String? resultTypeName;

  /// Whether the handler class has an unnamed constructor with no required arguments.
  final bool hasDefaultConstructor;

  /// Parameter name for factory function (e.g. `createUserCommandHandler`).
  String get paramName {
    if (className.isEmpty) return 'handler';
    return className[0].toLowerCase() + className.substring(1);
  }
}
