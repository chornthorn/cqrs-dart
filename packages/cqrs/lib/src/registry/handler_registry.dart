import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import 'default_handler_registry.dart';
import 'resolver_handler_registry.dart';

/// Function signature for constructing a handler instance on demand.
typedef HandlerFactory<T> = T Function();

/// Contract for registering and resolving CQRS command, query, and event handlers.
abstract interface class HandlerRegistry {
  /// Creates a default map-based in-process handler registry.
  factory HandlerRegistry() = DefaultHandlerRegistry;

  /// Creates a default map-based in-process handler registry.
  factory HandlerRegistry.defaultRegistry() = DefaultHandlerRegistry;

  /// Creates a handler registry backed by a custom resolver callback
  /// (e.g. for dependency injection containers like GetIt or Riverpod).
  factory HandlerRegistry.resolver({
    required HandlerResolver resolver,
    MultiHandlerResolver? multiResolver,
    EventResolver? eventResolver,
  }) = ResolverHandlerRegistry;

  /// Registers a factory for a [CommandHandler].
  void registerCommand<TCommand extends Command<TResult>, TResult>(
    HandlerFactory<CommandHandler<TCommand, TResult>> factory,
  );

  /// Registers a factory for a [QueryHandler].
  void registerQuery<TQuery extends Query<TResult>, TResult>(
    HandlerFactory<QueryHandler<TQuery, TResult>> factory,
  );

  /// Registers a factory for an [EventHandler].
  void registerEvent<TEvent extends DomainEvent>(
    HandlerFactory<EventHandler<TEvent>> factory,
  );

  /// Resolves the registered [CommandHandler] for [TCommand]. Returns null if not found.
  CommandHandler<TCommand, TResult>?
      resolveCommand<TCommand extends Command<TResult>, TResult>({
    Type? messageType,
  });

  /// Resolves the registered [QueryHandler] for [TQuery]. Returns null if not found.
  QueryHandler<TQuery, TResult>?
      resolveQuery<TQuery extends Query<TResult>, TResult>({
    Type? messageType,
  });

  /// Resolves all registered [EventHandler]s for [TEvent].
  List<EventHandler<TEvent>> resolveEvents<TEvent extends DomainEvent>({
    Type? eventType,
  });
}
