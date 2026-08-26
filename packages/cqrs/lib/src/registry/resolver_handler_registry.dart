import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import 'handler_registry.dart';

/// Handler resolver callback type.
typedef HandlerResolver = Object? Function(Type handlerType);

/// Multi-handler resolver callback type (for resolving all event handlers for an event).
typedef MultiHandlerResolver = List<dynamic> Function(Type handlerType);

/// Generic event resolver callback type for typed containers like GetIt.
typedef EventResolver = List<EventHandler<TEvent>> Function<TEvent extends DomainEvent>();

/// An adapter implementation of [HandlerRegistry] that delegates handler
/// resolution to an external container / service locator (such as GetIt, Riverpod, etc.).
class ResolverHandlerRegistry implements HandlerRegistry {
  ResolverHandlerRegistry({
    required this.resolver,
    this.multiResolver,
    this.eventResolver,
  });

  /// Custom function to resolve a single handler instance by its interface type.
  final HandlerResolver resolver;

  /// Custom function to resolve multiple handlers (useful for event subscribers).
  final MultiHandlerResolver? multiResolver;

  /// Generic function to resolve multiple event handlers by generic type.
  final EventResolver? eventResolver;

  @override
  void registerCommand<TCommand extends Command<TResult>, TResult>(
    HandlerFactory<CommandHandler<TCommand, TResult>> factory,
  ) {
    throw UnsupportedError(
      'ResolverHandlerRegistry is read-only and resolves from an external container.',
    );
  }

  @override
  void registerQuery<TQuery extends Query<TResult>, TResult>(
    HandlerFactory<QueryHandler<TQuery, TResult>> factory,
  ) {
    throw UnsupportedError(
      'ResolverHandlerRegistry is read-only and resolves from an external container.',
    );
  }

  @override
  void registerEvent<TEvent extends DomainEvent>(
    HandlerFactory<EventHandler<TEvent>> factory,
  ) {
    throw UnsupportedError(
      'ResolverHandlerRegistry is read-only and resolves from an external container.',
    );
  }

  @override
  CommandHandler<TCommand, TResult>?
      resolveCommand<TCommand extends Command<TResult>, TResult>({
    Type? messageType,
  }) {
    final handler = resolver(CommandHandler<TCommand, TResult>);
    return handler as CommandHandler<TCommand, TResult>?;
  }

  @override
  QueryHandler<TQuery, TResult>?
      resolveQuery<TQuery extends Query<TResult>, TResult>({
    Type? messageType,
  }) {
    final handler = resolver(QueryHandler<TQuery, TResult>);
    return handler as QueryHandler<TQuery, TResult>?;
  }

  @override
  List<EventHandler<TEvent>> resolveEvents<TEvent extends DomainEvent>({
    Type? eventType,
  }) {
    if (eventResolver != null) {
      return eventResolver!<TEvent>();
    }

    final targetType = EventHandler<TEvent>;
    if (multiResolver != null) {
      final handlers = multiResolver!(targetType);
      return handlers.map((h) => h as EventHandler<TEvent>).toList();
    }

    final single = resolver(targetType);
    if (single != null) {
      return [single as EventHandler<TEvent>];
    }

    return const [];
  }
}
