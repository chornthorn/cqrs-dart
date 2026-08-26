import '../contracts/event.dart';

/// Contract for publishing domain events.
abstract interface class EventPublisher {
  /// Publishes [event] to all registered [EventHandler] instances.
  Future<void> publish<TEvent extends DomainEvent>(TEvent event);

  /// Publishes a sequence of [events] sequentially or concurrently.
  Future<void> publishAll(Iterable<DomainEvent> events);
}
