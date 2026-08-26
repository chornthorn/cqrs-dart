/// An event signifying that a state change or significant action has occurred.
abstract class Event {
  const Event();
}

/// Handles a published event of type [TEvent].
abstract interface class EventHandler<TEvent extends Event> {
  /// Handles the given [event].
  Future<void> handle(TEvent event);
}
