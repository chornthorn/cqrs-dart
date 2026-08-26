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
    await _dispatcher.publish(EchoedEvent(command.value));
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
    log.add('$tag:before:${command.runtimeType}');
    final result = await next();
    log.add('$tag:after:${command.runtimeType}');
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
    log.add('$tag:before:${query.runtimeType}');
    final result = await next();
    log.add('$tag:after:${query.runtimeType}');
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
    NextEventHandler next,
  ) async {
    log.add('$tag:before:${event.runtimeType}');
    await next();
    log.add('$tag:after:${event.runtimeType}');
  }
}

void main() {
  group('DefaultCqrsDispatcher with DefaultHandlerRegistry', () {
    late DefaultHandlerRegistry registry;
    late DefaultCqrsDispatcher dispatcher;

    setUp(() {
      registry = DefaultHandlerRegistry();
      dispatcher = DefaultCqrsDispatcher(registry: registry);
    });

    test('query executes registered query handler', () async {
      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);

      final result = await dispatcher.query(PingQuery('pong'));
      expect(result, 'pong');
    });

    test('query throws HandlerNotFoundException when query handler is missing', () async {
      expect(
        () => dispatcher.query(PingQuery('hello')),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('command executes registered command handler and emits event', () async {
      registry.registerCommand<EchoCommand, int>(() => EchoCommandHandler(dispatcher));
      final received = <String>[];
      registry.registerEvent<EchoedEvent>(() => RecordingHandler('a', received));

      final result = await dispatcher.command(EchoCommand(42));
      expect(result, 42);
      expect(received, ['a:42']);
    });

    test('command throws HandlerNotFoundException when command handler is missing', () async {
      expect(
        () => dispatcher.command(EchoCommand(1)),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('streamQuery streams values from registered stream query handler', () async {
      registry.registerStreamQuery<CountStreamQuery, int>(CountStreamQueryHandler.new);

      final stream = dispatcher.streamQuery(CountStreamQuery(3));
      expect(await stream.toList(), [1, 2, 3]);
    });

    test('streamQuery throws HandlerNotFoundException when handler is missing', () {
      expect(
        () => dispatcher.streamQuery(CountStreamQuery(3)),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });

    test('publish broadcasts to multiple registered event handlers', () async {
      final log = <String>[];
      registry.registerEvent<EchoedEvent>(() => RecordingHandler('first', log));
      registry.registerEvent<EchoedEvent>(() => RecordingHandler('second', log));

      await dispatcher.publish(EchoedEvent(7));
      expect(log, containsAllInOrder(['first:7', 'second:7']));
    });

    test('publish does nothing when no handler is registered for event', () async {
      expect(() async => dispatcher.publish(UnusedEvent()), returnsNormally);
    });

    test('publishAll publishes all events in sequence', () async {
      final log = <String>[];
      registry.registerEvent<EchoedEvent>(() => RecordingHandler('rec', log));

      await dispatcher.publishAll([EchoedEvent(1), EchoedEvent(2)]);
      expect(log, ['rec:1', 'rec:2']);
    });

    test('throws DuplicateHandlerException on double command/query registration', () {
      registry.registerCommand<EchoCommand, int>(() => EchoCommandHandler(dispatcher));
      expect(
        () => registry.registerCommand<EchoCommand, int>(() => EchoCommandHandler(dispatcher)),
        throwsA(isA<DuplicateHandlerException>()),
      );

      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);
      expect(
        () => registry.registerQuery<PingQuery, String>(PingQueryHandler.new),
        throwsA(isA<DuplicateHandlerException>()),
      );

      registry.registerStreamQuery<CountStreamQuery, int>(CountStreamQueryHandler.new);
      expect(
        () => registry.registerStreamQuery<CountStreamQuery, int>(CountStreamQueryHandler.new),
        throwsA(isA<DuplicateHandlerException>()),
      );
    });

    test('registry.clear() removes all registered handlers', () async {
      registry.registerQuery<PingQuery, String>(PingQueryHandler.new);
      expect(registry.resolveQuery<PingQuery, String>(), isNotNull);

      registry.clear();
      expect(registry.resolveQuery<PingQuery, String>(), isNull);
    });
  });

  group('Middlewares', () {
    test('command middlewares execute in order (onion layer)', () async {
      final log = <String>[];
      final registry = DefaultHandlerRegistry()
        ..registerCommand<EchoCommand, int>(() => EchoCommandHandler(DefaultCqrsDispatcher()));

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        commandMiddlewares: [
          TrackingCommandMiddleware(log, 'm1'),
          TrackingCommandMiddleware(log, 'm2'),
        ],
      );

      final result = await dispatcher.command(EchoCommand(10));
      expect(result, 10);
      expect(log, [
        'm1:before:EchoCommand',
        'm2:before:EchoCommand',
        'm2:after:EchoCommand',
        'm1:after:EchoCommand',
      ]);
    });

    test('query middlewares execute in order', () async {
      final log = <String>[];
      final registry = DefaultHandlerRegistry()
        ..registerQuery<PingQuery, String>(PingQueryHandler.new);

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        queryMiddlewares: [
          TrackingQueryMiddleware(log, 'qm1'),
          TrackingQueryMiddleware(log, 'qm2'),
        ],
      );

      final result = await dispatcher.query(PingQuery('test'));
      expect(result, 'test');
      expect(log, [
        'qm1:before:PingQuery',
        'qm2:before:PingQuery',
        'qm2:after:PingQuery',
        'qm1:after:PingQuery',
      ]);
    });

    test('event middlewares execute around event handlers', () async {
      final log = <String>[];
      final registry = DefaultHandlerRegistry()
        ..registerEvent<EchoedEvent>(() => RecordingHandler('handler', log));

      final dispatcher = DefaultCqrsDispatcher(
        registry: registry,
        eventMiddlewares: [
          TrackingEventMiddleware(log, 'em1'),
        ],
      );

      await dispatcher.publish(EchoedEvent(5));
      expect(log, [
        'em1:before:EchoedEvent',
        'handler:5',
        'em1:after:EchoedEvent',
      ]);
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
      final result = await dispatcher.query(PingQuery('resolver_test'));
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

      final resolverRegistry = HandlerRegistry.resolver(
        resolver: (_) => null,
        multiResolver: (type) => multiMap[type] ?? const [],
      );

      final dispatcher = CqrsDispatcher(registry: resolverRegistry);
      await dispatcher.publish(EchoedEvent(99));

      expect(log, unorderedEquals(['x:99', 'y:99']));
    });
  });

  group('Factory constructors', () {
    test('HandlerRegistry() and HandlerRegistry.defaultRegistry() return DefaultHandlerRegistry', () {
      final r1 = HandlerRegistry();
      expect(r1, isA<DefaultHandlerRegistry>());

      final r2 = HandlerRegistry.defaultRegistry();
      expect(r2, isA<DefaultHandlerRegistry>());
    });

    test('CqrsDispatcher() creates internal DefaultHandlerRegistry accessible via dispatcher.registry', () async {
      final dispatcher = CqrsDispatcher();
      expect(dispatcher.registry, isA<DefaultHandlerRegistry>());

      dispatcher.registry.registerQuery<PingQuery, String>(PingQueryHandler.new);
      final result = await dispatcher.query(PingQuery('auto_registry'));
      expect(result, 'auto_registry');
    });

    test('CqrsDispatcher(registry: customRegistry) uses provided registry', () async {
      final customRegistry = DefaultHandlerRegistry();
      final dispatcher = CqrsDispatcher(registry: customRegistry);
      expect(dispatcher.registry, same(customRegistry));
    });
  });
}
