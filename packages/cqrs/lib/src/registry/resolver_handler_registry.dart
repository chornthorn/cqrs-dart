import '../contracts/command.dart';
import '../contracts/event.dart';
import '../contracts/query.dart';
import '../contracts/stream_query.dart';
import 'handler_registry.dart';

/// Handler registry backed by a generic resolver function (e.g., GetIt or custom IoC container).
class ResolverHandlerRegistry implements HandlerRegistry {
  /// Creates a [ResolverHandlerRegistry] using the specified [resolver] and optional multi-resolvers.
  ResolverHandlerRegistry({
    required this.resolver,
    this.multiResolver,
    this.eventResolver,
  });

  /// Resolver for single instances (e.g. `(Type t) => getIt.get(type: t)`).
  final Object? Function(Type type) resolver;

  /// Resolver for multiple instances by [Type] (e.g. `(Type t) => myContainer.getAll(t)`).
  final Iterable<dynamic> Function(Type type)? multiResolver;

  /// Generic resolver for multiple event handlers (e.g. `<E extends DomainEvent>() => getIt.getAll<EventHandler<E>>().toList()`).
  final List<EventHandler<TEvent>> Function<TEvent extends DomainEvent>()?
      eventResolver;

  @override
  void registerCommand<TCommand extends Command<TResult>, TResult>(
    HandlerFactory<CommandHandler<TCommand, TResult>> factory,
  ) {
    throw UnsupportedError(
      'Registering handlers directly on ResolverHandlerRegistry is unsupported. '
      'Register handlers directly in your IoC container.',
    );
  }

  @override
  void registerQuery<TQuery extends Query<TResult>, TResult>(
    HandlerFactory<QueryHandler<TQuery, TResult>> factory,
  ) {
    throw UnsupportedError(
      'Registering handlers directly on ResolverHandlerRegistry is unsupported. '
      'Register handlers directly in your IoC container.',
    );
  }

  @override
  void registerStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>(
    HandlerFactory<StreamQueryHandler<TStreamQuery, TResult>> factory,
  ) {
    throw UnsupportedError(
      'Registering handlers directly on ResolverHandlerRegistry is unsupported. '
      'Register handlers directly in your IoC container.',
    );
  }

  @override
  void registerEvent<TEvent extends DomainEvent>(
    HandlerFactory<EventHandler<TEvent>> factory,
  ) {
    throw UnsupportedError(
      'Registering handlers directly on ResolverHandlerRegistry is unsupported. '
      'Register handlers directly in your IoC container.',
    );
  }

  @override
  CommandHandler<TCommand, TResult>?
      resolveCommand<TCommand extends Command<TResult>, TResult>({Type? messageType}) {
    final handler = resolver(CommandHandler<TCommand, TResult>);
    return handler as CommandHandler<TCommand, TResult>?;
  }

  @override
  QueryHandler<TQuery, TResult>?
      resolveQuery<TQuery extends Query<TResult>, TResult>({Type? messageType}) {
    final handler = resolver(QueryHandler<TQuery, TResult>);
    return handler as QueryHandler<TQuery, TResult>?;
  }

  @override
  StreamQueryHandler<TStreamQuery, TResult>?
      resolveStreamQuery<TStreamQuery extends StreamQuery<TResult>, TResult>({Type? messageType}) {
    final handler = resolver(StreamQueryHandler<TStreamQuery, TResult>);
    return handler as StreamQueryHandler<TStreamQuery, TResult>?;
  }

  @override
  List<EventHandler<TEvent>> resolveEvents<TEvent extends DomainEvent>({Type? eventType}) {
    if (eventResolver != null) {
      return eventResolver!<TEvent>();
    }
    if (multiResolver != null) {
      final handlers = multiResolver!(EventHandler<TEvent>);
      return handlers.cast<EventHandler<TEvent>>().toList(growable: false);
    }
    final single = resolver(EventHandler<TEvent>);
    if (single is EventHandler<TEvent>) {
      return [single];
    }
    return const [];
  }
}
