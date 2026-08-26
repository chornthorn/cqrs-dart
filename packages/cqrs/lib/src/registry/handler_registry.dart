import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import '../contracts/stream_query.dart';

/// Factory function to instantiate a handler.
typedef HandlerFactory<T> = T Function();

/// Pluggable resolver function for looking up handlers dynamically.
typedef HandlerResolver = Object? Function(Type handlerType);

/// Contract for registering and resolving CQRS handlers.
abstract interface class HandlerRegistry {
  /// Registers a factory for a [CommandHandler].
  void registerCommand<TCommand extends Command<TResult>, TResult>(
    HandlerFactory<CommandHandler<TCommand, TResult>> factory,
  );

  /// Registers a factory for a [QueryHandler].
  void registerQuery<TQuery extends Query<TResult>, TResult>(
    HandlerFactory<QueryHandler<TQuery, TResult>> factory,
  );

  /// Registers a factory for a [StreamQueryHandler].
  void registerStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>(
    HandlerFactory<StreamQueryHandler<TStreamQuery, TResult>> factory,
  );

  /// Registers a factory for an [EventHandler]. Multiple handlers per event type are allowed.
  void registerEvent<TEvent extends DomainEvent>(
    HandlerFactory<EventHandler<TEvent>> factory,
  );

  /// Resolves the registered [CommandHandler] for [TCommand]. Returns null if not found.
  CommandHandler<TCommand, TResult>?
      resolveCommand<TCommand extends Command<TResult>, TResult>({Type? messageType});

  /// Resolves the registered [QueryHandler] for [TQuery]. Returns null if not found.
  QueryHandler<TQuery, TResult>?
      resolveQuery<TQuery extends Query<TResult>, TResult>({Type? messageType});

  /// Resolves the registered [StreamQueryHandler] for [TStreamQuery]. Returns null if not found.
  StreamQueryHandler<TStreamQuery, TResult>?
      resolveStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>({Type? messageType});

  /// Resolves all registered [EventHandler] instances for [TEvent] (or [eventType]).
  List<EventHandler<TEvent>> resolveEvents<TEvent extends DomainEvent>({Type? eventType});
}
