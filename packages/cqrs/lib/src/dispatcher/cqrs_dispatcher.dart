import 'command_dispatcher.dart';
import 'event_publisher.dart';
import 'query_dispatcher.dart';

/// Unified CQRS entry point combining commands, queries, and events.
abstract interface class CqrsDispatcher
    implements CommandDispatcher, QueryDispatcher, EventPublisher {}
