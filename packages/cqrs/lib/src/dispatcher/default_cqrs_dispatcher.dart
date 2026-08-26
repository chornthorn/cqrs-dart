import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import '../contracts/stream_query.dart';
import '../exceptions/cqrs_exceptions.dart';
import '../pipeline/middleware.dart';
import '../pipeline/pipeline_runner.dart';
import '../registry/handler_registry.dart';
import '../registry/in_memory_handler_registry.dart';
import 'cqrs_dispatcher.dart';

/// Default pure Dart implementation of [CqrsDispatcher].
class DefaultCqrsDispatcher implements CqrsDispatcher {
  /// Creates a [DefaultCqrsDispatcher] with optional registry and middlewares.
  DefaultCqrsDispatcher({
    HandlerRegistry? registry,
    List<CommandMiddleware>? commandMiddlewares,
    List<QueryMiddleware>? queryMiddlewares,
    List<EventMiddleware>? eventMiddlewares,
  })  : _registry = registry ?? InMemoryHandlerRegistry(),
        _commandMiddlewares = commandMiddlewares ?? const [],
        _queryMiddlewares = queryMiddlewares ?? const [],
        _eventMiddlewares = eventMiddlewares ?? const [];

  final HandlerRegistry _registry;
  final List<CommandMiddleware> _commandMiddlewares;
  final List<QueryMiddleware> _queryMiddlewares;
  final List<EventMiddleware> _eventMiddlewares;

  /// The underlying handler registry.
  HandlerRegistry get registry => _registry;

  @override
  Future<TResult> dispatchCommand<TCommand extends Command<TResult>, TResult>(
    TCommand command,
  ) {
    final handler = _registry.resolveCommand<TCommand, TResult>(
      messageType: command.runtimeType,
    );
    if (handler == null) {
      throw HandlerNotFoundException(command.runtimeType);
    }

    if (_commandMiddlewares.isEmpty) {
      return handler.execute(command);
    }

    return PipelineRunner.runCommand(
      command: command,
      middlewares: _commandMiddlewares,
      handler: () => handler.execute(command),
    );
  }

  @override
  Future<TResult> dispatchQuery<TQuery extends Query<TResult>, TResult>(
    TQuery query,
  ) {
    final handler = _registry.resolveQuery<TQuery, TResult>(
      messageType: query.runtimeType,
    );
    if (handler == null) {
      throw HandlerNotFoundException(query.runtimeType);
    }

    if (_queryMiddlewares.isEmpty) {
      return handler.execute(query);
    }

    return PipelineRunner.runQuery(
      query: query,
      middlewares: _queryMiddlewares,
      handler: () => handler.execute(query),
    );
  }

  @override
  Stream<TResult>
      dispatchStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>(
    TStreamQuery query,
  ) {
    final handler = _registry.resolveStreamQuery<TStreamQuery, TResult>(
      messageType: query.runtimeType,
    );
    if (handler == null) {
      throw HandlerNotFoundException(query.runtimeType);
    }

    return handler.execute(query);
  }

  @override
  Future<void> publishEvent<TEvent extends DomainEvent>(TEvent event) {
    final handlers = _registry.resolveEvents<TEvent>(
      eventType: event.runtimeType,
    );
    if (handlers.isEmpty) {
      return Future.value();
    }

    Future<void> executeHandlers() async {
      await Future.wait(handlers.map((h) => h.handle(event)));
    }

    if (_eventMiddlewares.isEmpty) {
      return executeHandlers();
    }

    return PipelineRunner.runEvent(
      event: event,
      middlewares: _eventMiddlewares,
      handler: executeHandlers,
    );
  }

  @override
  Future<void> publishAll(Iterable<DomainEvent> events) async {
    for (final event in events) {
      await publishEvent(event);
    }
  }
}
