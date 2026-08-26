/// A domain event signifying that a state change has occurred.
abstract class DomainEvent {
  const DomainEvent();
}

/// Handles a published domain event of type [TEvent].
abstract interface class EventHandler<TEvent extends DomainEvent> {
  /// Handles the given domain [event].
  Future<void> handle(TEvent event);
}
