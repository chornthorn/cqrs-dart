/// A fact that already occurred in the domain.
abstract class DomainEvent {
  /// Creates a [DomainEvent] with optional [occurredOn] timestamp (defaults to [DateTime.now]).
  DomainEvent({DateTime? occurredOn})
      : occurredOn = occurredOn ?? DateTime.now();

  /// The timestamp when the event occurred.
  final DateTime occurredOn;
}

/// Reacts to a [DomainEvent]. Multiple handlers can listen to the same event.
abstract interface class EventHandler<TEvent extends DomainEvent> {
  /// Handles the published [event].
  Future<void> handle(TEvent event);
}
