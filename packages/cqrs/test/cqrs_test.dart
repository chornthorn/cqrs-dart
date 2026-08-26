import 'dart:async';

import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

// Test Messages & Handlers
class PingQuery implements Query<String> {
  PingQuery(this.message);
  final String message;
}

class PingQueryHandler implements QueryHandler<PingQuery, String> {
  @override
  Future<String> execute(PingQuery query) async => query.message;
}

class CountStreamQuery implements StreamQuery<int> {
  CountStreamQuery(this.count);
  final int count;
}

class CountStreamQueryHandler
    implements StreamQueryHandler<CountStreamQuery, int> {
  @override
  Stream<int> execute(CountStreamQuery query) {
    return Stream.fromIterable(List.generate(query.count, (i) => i + 1));
  }
}

class EchoCommand implements Command<int> {
  EchoCommand(this.value);
  final int value;
}

class EchoCommandHandler implements CommandHandler<EchoCommand, int> {
  EchoCommandHandler(this._dispatcher);
  final EventPublisher _dispatcher;

  @override
  Future<int> execute(EchoCommand command) async {
    await _dispatcher.publishEvent(EchoedEvent(command.value));
    return command.value;
  }
}

class EchoedEvent extends DomainEvent {
  EchoedEvent(this.value);
  final int value;
}

class UnusedEvent extends DomainEvent {}

class RecordingHandler implements EventHandler<EchoedEvent> {
  RecordingHandler(this.label, this.log);
  final String label;
  final List<String> log;

  @override
  Future<void> handle(EchoedEvent event) async {
    log.add('$label:${event.value}');
  }
}

// Test Middlewares
class TrackingCommandMiddleware implements CommandMiddleware {
  TrackingCommandMiddleware(this.log, this.tag);
  final List<String> log;
  final String tag;

  @override
  Future<TResult> handle<TCommand extends Command<TResult>, TResult>(
    TCommand command,
    NextHandler<TResult> next,
  ) async {
    log.add('before:$tag');
    final result = await next();
    log.add('after:$tag');
    return result;
  }
}

class TrackingQueryMiddleware implements QueryMiddleware {
  TrackingQueryMiddleware(this.log, this.tag);
  final List<String> log;
  final String tag;

  @override
  Future<TResult> handle<TQuery extends Query<TResult>, TResult>(
    TQuery query,
    NextHandler<TResult> next,
  ) async {
    log.add('query_before:$tag');
    final result = await next();
    log.add('query_after:$tag');
    return result;
  }
}

class TrackingEventMiddleware implements EventMiddleware {
  TrackingEventMiddleware(this.log, this.tag);
  final List<String> log;
  final String tag;

  @override
  Future<void> handle<TEvent extends DomainEvent>(
    TEvent event,
    Future<void> Function() next,
  ) async {
    log.add('event_before:$tag');
    await next();
    log.add('event_after:$tag');
  }
}

void main() {
  group('DefaultCqrsDispatcher with InMemoryHandlerRegistry', () {
    late InMemoryHandlerRegistry registry;
    late DefaultCqrsDispatcher dispatcher;

    setUp(() {
      registry = InMemoryHandlerRegistry();
      dispatcher = DefaultCqrsDispatcher(registry: registry);
    });

    test('executes query handler and returns result', () async {
      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);

      final result = await dispatcher.dispatchQuery(PingQuery('hello'));
      expect(result, 'hello');
    });

    test('throws HandlerNotFoundException when query handler is not registered',
        () async {
      expect(
        () => dispatcher.dispatchQuery(PingQuery('hello')),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('executes stream query handler and emits stream events', () async {
      registry.registerStreamQuery<CountStreamQuery, int>(
        CountStreamQueryHandler.new,
      );

      final stream = dispatcher.dispatchStreamQuery(CountStreamQuery(3));
      expect(await stream.toList(), [1, 2, 3]);
    });

    test('throws HandlerNotFoundException when stream query handler not registered',
        () {
      expect(
        () => dispatcher.dispatchStreamQuery(CountStreamQuery(3)),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('executes command handler and publishes events to listeners',
        () async {
      final log = <String>[];
      registry.registerCommand<EchoCommand, int>(
        () => EchoCommandHandler(dispatcher),
      );
      registry.registerEvent<EchoedEvent>(
        () => RecordingHandler('a', log),
      );
      registry.registerEvent<EchoedEvent>(
        () => RecordingHandler('b', log),
      );

      final result = await dispatcher.dispatchCommand(EchoCommand(42));
      expect(result, 42);
      expect(log, unorderedEquals(['a:42', 'b:42']));
    });

    test('throws HandlerNotFoundException when command handler is not registered',
        () async {
      expect(
        () => dispatcher.dispatchCommand(EchoCommand(1)),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('publishEvent is a no-op when no event handlers are registered',
        () async {
      await expectLater(
        dispatcher.publishEvent(UnusedEvent()),
        completes,
      );
    });

    test('publishAll publishes all events in sequence', () async {
      final log = <String>[];
      registry.registerEvent<EchoedEvent>(() => RecordingHandler('seq', log));

      await dispatcher.publishAll([
        EchoedEvent(1),
        EchoedEvent(2),
        EchoedEvent(3),
      ]);

      expect(log, ['seq:1', 'seq:2', 'seq:3']);
    });

    test('throws DuplicateHandlerException on double command/query registration',
        () {
      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);
      expect(
        () => registry.registerQuery<PingQuery, String>(PingQueryHandler.new),
        throwsA(isA<DuplicateHandlerException>()),
      );

      registry.registerCommand<EchoCommand, int>(
        () => EchoCommandHandler(dispatcher),
      );
      expect(
        () => registry.registerCommand<EchoCommand, int>(
          () => EchoCommandHandler(dispatcher),
        ),
        throwsA(isA<DuplicateHandlerException>()),
      );
    });

    test('registry.clear() removes all registered handlers', () {
      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);
      expect(registry.resolveQuery<PingQuery, String>(), isNotNull);

      registry.clear();
      expect(registry.resolveQuery<PingQuery, String>(), isNull);
    });
  });

  group('Middlewares', () {
    test('command middlewares execute in order (onion layer)', () async {
      final pipelineLog = <String>[];
      final registry = InMemoryHandlerRegistry()
        ..registerCommand<EchoCommand, int>(
          () => EchoCommandHandler(DefaultCqrsDispatcher()),
        );

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        commandMiddlewares: [
          TrackingCommandMiddleware(pipelineLog, 'm1'),
          TrackingCommandMiddleware(pipelineLog, 'm2'),
        ],
      );

      final result = await dispatcher.dispatchCommand(EchoCommand(10));
      expect(result, 10);
      expect(pipelineLog, [
        'before:m1',
        'before:m2',
        'after:m2',
        'after:m1',
      ]);
    });

    test('query middlewares execute in order', () async {
      final pipelineLog = <String>[];
      final registry = InMemoryHandlerRegistry()
        ..registerQuery<PingQuery, String>(PingQueryHandler.new);

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        queryMiddlewares: [
          TrackingQueryMiddleware(pipelineLog, 'q1'),
          TrackingQueryMiddleware(pipelineLog, 'q2'),
        ],
      );

      final result = await dispatcher.dispatchQuery(PingQuery('test'));
      expect(result, 'test');
      expect(pipelineLog, [
        'query_before:q1',
        'query_before:q2',
        'query_after:q2',
        'query_after:q1',
      ]);
    });

    test('event middlewares execute around event handlers', () async {
      final pipelineLog = <String>[];
      final eventLog = <String>[];
      final registry = InMemoryHandlerRegistry()
        ..registerEvent<EchoedEvent>(() => RecordingHandler('h', eventLog));

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        eventMiddlewares: [
          TrackingEventMiddleware(pipelineLog, 'e1'),
        ],
      );

      await dispatcher.publishEvent(EchoedEvent(5));
      expect(eventLog, ['h:5']);
      expect(pipelineLog, ['event_before:e1', 'event_after:e1']);
    });
  });

  group('ResolverHandlerRegistry', () {
    test('resolves handlers via custom resolver map/container', () async {
      final map = <Type, Object>{
        QueryHandler<PingQuery, String>: PingQueryHandler(),
      };

      final resolverRegistry = ResolverHandlerRegistry(
        resolver: (type) => map[type],
      );

      final dispatcher = DefaultCqrsDispatcher(registry: resolverRegistry);
      final result = await dispatcher.dispatchQuery(PingQuery('resolver_test'));
      expect(result, 'resolver_test');
    });

    test('resolves multiple events via multiResolver', () async {
      final log = <String>[];
      final multiMap = <Type, List<dynamic>>{
        EventHandler<EchoedEvent>: [
          RecordingHandler('x', log),
          RecordingHandler('y', log),
        ],
      };

      final resolverRegistry = ResolverHandlerRegistry(
        resolver: (_) => null,
        multiResolver: (type) => multiMap[type] ?? const [],
      );

      final dispatcher = DefaultCqrsDispatcher(registry: resolverRegistry);
      await dispatcher.publishEvent(EchoedEvent(99));

      expect(log, unorderedEquals(['x:99', 'y:99']));
    });
  });
}
