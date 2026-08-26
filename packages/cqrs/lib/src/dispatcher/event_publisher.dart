import '../contracts/event.dart';

/// Contract for publishing application/domain events.
abstract interface class EventPublisher {
  /// Publishes an [event] to all registered handlers for [TEvent].
  Future<void> publish<TEvent extends Event>(TEvent event);

  /// Publishes multiple [events] in sequential order.
  Future<void> publishAll(Iterable<Event> events);
}
