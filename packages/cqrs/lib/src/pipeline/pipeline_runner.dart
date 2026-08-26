import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import 'middleware.dart';

/// Helper to execute middleware chains in onion-layer order.
class PipelineRunner {
  const PipelineRunner._();

  /// Runs [middlewares] in order around [handler].
  static Future<TResult> runCommand<TCommand extends Command<TResult>, TResult>({
    required TCommand command,
    required List<CommandMiddleware> middlewares,
    required Future<TResult> Function() handler,
  }) {
    Future<TResult> executeStep(int index) {
      if (index >= middlewares.length) {
        return handler();
      }
      return middlewares[index].handle<TCommand, TResult>(
        command,
        () => executeStep(index + 1),
      );
    }

    return executeStep(0);
  }

  /// Runs [middlewares] in order around [handler].
  static Future<TResult> runQuery<TQuery extends Query<TResult>, TResult>({
    required TQuery query,
    required List<QueryMiddleware> middlewares,
    required Future<TResult> Function() handler,
  }) {
    Future<TResult> executeStep(int index) {
      if (index >= middlewares.length) {
        return handler();
      }
      return middlewares[index].handle<TQuery, TResult>(
        query,
        () => executeStep(index + 1),
      );
    }

    return executeStep(0);
  }

  /// Runs [middlewares] in order around [handler].
  static Future<void> runEvent<TEvent extends DomainEvent>({
    required TEvent event,
    required List<EventMiddleware> middlewares,
    required Future<void> Function() handler,
  }) {
    Future<void> executeStep(int index) {
      if (index >= middlewares.length) {
        return handler();
      }
      return middlewares[index].handle<TEvent>(
        event,
        () => executeStep(index + 1),
      );
    }

    return executeStep(0);
  }
}
