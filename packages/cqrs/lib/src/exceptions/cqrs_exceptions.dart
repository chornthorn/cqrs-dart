/// Base exception for CQRS-related errors.
class CqrsException implements Exception {
  /// Creates a [CqrsException] with a given [message].
  const CqrsException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'CqrsException: $message';
}

/// Thrown when no handler is found for a given message type.
class HandlerNotFoundException extends CqrsException {
  /// Creates a [HandlerNotFoundException] for the missing handler type.
  HandlerNotFoundException(Type messageType)
      : super('No handler found for message of type $messageType');
}

/// Thrown when attempting to register a duplicate single-instance handler (e.g. Command or Query).
class DuplicateHandlerException extends CqrsException {
  /// Creates a [DuplicateHandlerException] for the duplicate message type.
  DuplicateHandlerException(Type messageType)
      : super('Handler already registered for message of type $messageType');
}
