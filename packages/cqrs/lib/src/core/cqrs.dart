/// A read request that returns [TResult] without mutating state.
abstract class Query<TResult> {}

/// A write request that returns [TResult] after mutating state.
abstract class Command<TResult> {}

/// A fact that already happened in the domain.
abstract class DomainEvent {}

/// Executes a [Query] and returns its result.
abstract class QueryHandler<TQuery extends Query<TResult>, TResult> {
  Future<TResult> execute(TQuery query);
}

/// Executes a [Command] and returns its result.
abstract class CommandHandler<TCommand extends Command<TResult>, TResult> {
  Future<TResult> execute(TCommand command);
}

/// Reacts to a [DomainEvent]. Many handlers may listen to the same event.
abstract class EventHandler<TEvent extends DomainEvent> {
  Future<void> handle(TEvent event);
}
