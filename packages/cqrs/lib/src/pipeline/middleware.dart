import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';

/// Continuation callback signature for command and query pipelines.
typedef NextHandler<TResult> = Future<TResult> Function();

/// Continuation callback signature for event pipelines.
typedef NextEventHandler = Future<void> Function();

/// Middleware for intercepting command execution.
abstract interface class CommandMiddleware {
  /// Intercepts command execution before/after calling [next].
  Future<TResult> handle<TCommand extends Command<TResult>, TResult>(
    TCommand command,
    NextHandler<TResult> next,
  );
}

/// Middleware for intercepting query execution.
abstract interface class QueryMiddleware {
  /// Intercepts query execution before/after calling [next].
  Future<TResult> handle<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    NextHandler<TResult> next,
  );
}

/// Middleware for intercepting domain/integration event dispatching.
abstract interface class EventMiddleware {
  /// Intercepts event execution before/after calling [next].
  Future<void> handle<TEvent extends Event>(
    TEvent event,
    NextEventHandler next,
  );
}
