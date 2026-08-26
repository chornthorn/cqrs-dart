import '../pipeline/middleware.dart';
import '../registry/handler_registry.dart';
import 'command_dispatcher.dart';
import 'default_cqrs_dispatcher.dart';
import 'event_publisher.dart';
import 'query_dispatcher.dart';

/// Unified CQRS entry point combining commands, queries, and events.
abstract interface class CqrsDispatcher
    implements CommandDispatcher, QueryDispatcher, EventPublisher {
  /// Creates a default [CqrsDispatcher] with optional registry and middlewares.
  factory CqrsDispatcher({
    HandlerRegistry? registry,
    List<CommandMiddleware>? commandMiddlewares,
    List<QueryMiddleware>? queryMiddlewares,
    List<EventMiddleware>? eventMiddlewares,
  }) = DefaultCqrsDispatcher;
}
