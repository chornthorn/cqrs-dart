import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import 'middleware.dart';

/// Helper to execute middleware chains in onion-style nesting.
class PipelineRunner {
  PipelineRunner._();

  /// Runs [command] through [middlewares] and finally executes [handler].
  static Future<TResult> runCommand<TCommand extends Command<TResult>, TResult>({
    required TCommand command,
    required List<CommandMiddleware> middlewares,
    required Future<TResult> Function() handler,
  }) {
    if (middlewares.isEmpty) return handler();

    NextHandler<TResult> next = handler;
    for (var i = middlewares.length - 1; i >= 0; i--) {
      final middleware = middlewares[i];
      final currentNext = next;
      next = () => middleware.handle(command, currentNext);
    }

    return next();
  }

  /// Runs [query] through [middlewares] and finally executes [handler].
  static Future<TResult> runQuery<TQuery extends Query<TResult>, TResult>({
    required TQuery query,
    required List<QueryMiddleware> middlewares,
    required Future<TResult> Function() handler,
  }) {
    if (middlewares.isEmpty) return handler();

    NextHandler<TResult> next = handler;
    for (var i = middlewares.length - 1; i >= 0; i--) {
      final middleware = middlewares[i];
      final currentNext = next;
      next = () => middleware.handle(query, currentNext);
    }

    return next();
  }

  /// Runs [event] through [middlewares] and finally executes [handler].
  static Future<void> runEvent<TEvent extends Event>({
    required TEvent event,
    required List<EventMiddleware> middlewares,
    required Future<void> Function() handler,
  }) {
    if (middlewares.isEmpty) return handler();

    NextEventHandler next = handler;
    for (var i = middlewares.length - 1; i >= 0; i--) {
      final middleware = middlewares[i];
      final currentNext = next;
      next = () => middleware.handle(event, currentNext);
    }

    return next();
  }
}
