import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import '../exceptions/cqrs_exceptions.dart';
import 'handler_registry.dart';

/// Default in-memory implementation of [HandlerRegistry].
class DefaultHandlerRegistry implements HandlerRegistry {
  final Map<Type, HandlerFactory<dynamic>> _commandHandlers = {};
  final Map<Type, HandlerFactory<dynamic>> _queryHandlers = {};
  final Map<Type, List<HandlerFactory<dynamic>>> _eventHandlers = {};

  @override
  void registerCommand<TCommand extends Command<TResult>, TResult>(
    HandlerFactory<CommandHandler<TCommand, TResult>> factory,
  ) {
    if (_commandHandlers.containsKey(TCommand)) {
      throw DuplicateHandlerException(TCommand);
    }
    _commandHandlers[TCommand] = factory;
  }

  @override
  void registerQuery<TQuery extends Query<TResult>, TResult>(
    HandlerFactory<QueryHandler<TQuery, TResult>> factory,
  ) {
    if (_queryHandlers.containsKey(TQuery)) {
      throw DuplicateHandlerException(TQuery);
    }
    _queryHandlers[TQuery] = factory;
  }

  @override
  void registerEvent<TEvent extends DomainEvent>(
    HandlerFactory<EventHandler<TEvent>> factory,
  ) {
    _eventHandlers.putIfAbsent(TEvent, () => []).add(factory);
  }

  @override
  CommandHandler<TCommand, TResult>?
      resolveCommand<TCommand extends Command<TResult>, TResult>({
    Type? messageType,
  }) {
    final type = messageType ?? TCommand;
    final factory = _commandHandlers[type];
    if (factory == null) return null;
    return factory() as CommandHandler<TCommand, TResult>;
  }

  @override
  QueryHandler<TQuery, TResult>?
      resolveQuery<TQuery extends Query<TResult>, TResult>({
    Type? messageType,
  }) {
    final type = messageType ?? TQuery;
    final factory = _queryHandlers[type];
    if (factory == null) return null;
    return factory() as QueryHandler<TQuery, TResult>;
  }

  @override
  List<EventHandler<TEvent>> resolveEvents<TEvent extends DomainEvent>({
    Type? eventType,
  }) {
    final type = eventType ?? TEvent;
    final factories = _eventHandlers[type];
    if (factories == null || factories.isEmpty) return const [];
    return factories
        .map((f) => f() as EventHandler<TEvent>)
        .toList(growable: false);
  }

  /// Clears all registered handlers.
  void clear() {
    _commandHandlers.clear();
    _queryHandlers.clear();
    _eventHandlers.clear();
  }
}
