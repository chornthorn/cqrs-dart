import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

final getIt = GetIt.instance;

class PingQuery extends Query<String> {
  PingQuery(this.message);

  final String message;
}

class PingQueryHandler implements QueryHandler<PingQuery, String> {
  @override
  Future<String> execute(PingQuery query) async => query.message;
}

class EchoCommand extends Command<int> {
  EchoCommand(this.value);

  final int value;
}

class EchoedEvent extends DomainEvent {
  EchoedEvent(this.value);

  final int value;
}

class UnusedEvent extends DomainEvent {}

class EchoCommandHandler implements CommandHandler<EchoCommand, int> {
  EchoCommandHandler(this._dispatcher);

  final CqrsDispatcher _dispatcher;

  @override
  Future<int> execute(EchoCommand command) async {
    await _dispatcher.publishEvent(EchoedEvent(command.value));
    return command.value;
  }
}

class RecordingHandler implements EventHandler<EchoedEvent> {
  RecordingHandler(this.label, this.log);

  final String label;
  final List<String> log;

  @override
  Future<void> handle(EchoedEvent event) async {
    log.add('$label:${event.value}');
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.enableRegisteringMultipleInstancesOfOneType();
    getIt.registerSingleton(CqrsDispatcher());
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('dispatchQuery executes the registered query handler', () async {
    getIt.registerFactory<QueryHandler<PingQuery, String>>(
      PingQueryHandler.new,
    );

    final result = await getIt<CqrsDispatcher>().dispatchQuery(
      PingQuery('hello'),
    );

    expect(result, 'hello');
  });

  test(
    'dispatchCommand executes the handler and notifies every event listener',
    () async {
      final log = <String>[];
      getIt.registerFactory<CommandHandler<EchoCommand, int>>(
        () => EchoCommandHandler(getIt<CqrsDispatcher>()),
      );
      getIt.registerFactory<EventHandler<EchoedEvent>>(
        () => RecordingHandler('a', log),
      );
      getIt.registerFactory<EventHandler<EchoedEvent>>(
        () => RecordingHandler('b', log),
      );

      final result = await getIt<CqrsDispatcher>().dispatchCommand(
        EchoCommand(7),
      );

      expect(result, 7);
      expect(log, unorderedEquals(['a:7', 'b:7']));
    },
  );

  test('publishEvent is a no-op when no handlers are registered', () async {
    await getIt<CqrsDispatcher>().publishEvent(UnusedEvent());
  });
}
