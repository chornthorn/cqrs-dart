import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';

/// Callback invoked to proceed to the next step in a pipeline.
typedef NextHandler<TResult> = Future<TResult> Function();

/// Middleware for intercepting command execution.
abstract interface class CommandMiddleware {
  /// Intercepts the given [command]. Call [next] to continue the execution chain.
  Future<TResult> handle<TCommand extends Command<TResult>, TResult>(
    TCommand command,
    NextHandler<TResult> next,
  );
}

/// Middleware for intercepting query execution.
abstract interface class QueryMiddleware {
  /// Intercepts the given [query]. Call [next] to continue the execution chain.
  Future<TResult> handle<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    NextHandler<TResult> next,
  );
}

/// Middleware for intercepting event publication.
abstract interface class EventMiddleware {
  /// Intercepts the published [event]. Call [next] to continue event handling.
  Future<void> handle<TEvent extends DomainEvent>(
    TEvent event,
    Future<void> Function() next,
  );
}
