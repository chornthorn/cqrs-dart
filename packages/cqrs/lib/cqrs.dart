/// Pure Dart CQRS and event-driven architecture library.
library;

// Contracts
export 'src/contracts/command.dart';
export 'src/contracts/event.dart';
export 'src/contracts/query.dart';
export 'src/contracts/stream_query.dart';
// Dispatchers
export 'src/dispatcher/command_dispatcher.dart';
export 'src/dispatcher/cqrs_dispatcher.dart';
export 'src/dispatcher/default_cqrs_dispatcher.dart';
export 'src/dispatcher/event_publisher.dart';
export 'src/dispatcher/query_dispatcher.dart';
// Exceptions
export 'src/exceptions/cqrs_exceptions.dart';
// Pipeline / Middleware
export 'src/pipeline/middleware.dart';
export 'src/pipeline/pipeline_runner.dart';
// Registry
export 'src/registry/handler_registry.dart';
export 'src/registry/in_memory_handler_registry.dart';
export 'src/registry/resolver_handler_registry.dart';
