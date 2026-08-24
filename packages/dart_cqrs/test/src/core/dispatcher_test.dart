import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

final getIt = GetIt.instance;

class TestQuery extends Query<String> {
  TestQuery(this.payload);
  final String payload;
}

class TestQueryHandler implements QueryHandler<TestQuery, String> {
  @override
  Future<String> execute(TestQuery query) async => 'result:${query.payload}';
}

class TestCommand extends Command<int> {
  TestCommand(this.amount);
  final int amount;
}

class TestEvent extends DomainEvent {
  TestEvent(this.data);
  final String data;
}

class UnregisteredEvent extends DomainEvent {}

class TestCommandHandler implements CommandHandler<TestCommand, int> {
  TestCommandHandler(this._dispatcher);

  final CqrsDispatcher _dispatcher;

  @override
  Future<int> execute(TestCommand command) async {
    await _dispatcher.publishEvent(TestEvent('cmd:${command.amount}'));
    return command.amount * 2;
  }
}

class FirstEventHandler implements EventHandler<TestEvent> {
  FirstEventHandler(this.log);
  final List<String> log;

  @override
  Future<void> handle(TestEvent event) async {
    log.add('first:${event.data}');
  }
}

class SecondEventHandler implements EventHandler<TestEvent> {
  SecondEventHandler(this.log);
  final List<String> log;

  @override
  Future<void> handle(TestEvent event) async {
    log.add('second:${event.data}');
  }
}

void main() {
  group('CqrsDispatcher', () {
    late CqrsDispatcher dispatcher;

    setUp(() async {
      await getIt.reset();
      getIt.enableRegisteringMultipleInstancesOfOneType();
      dispatcher = CqrsDispatcher();
      getIt.registerSingleton<CqrsDispatcher>(dispatcher);
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'dispatchQuery successfully resolves and executes QueryHandler',
      () async {
        getIt.registerFactory<QueryHandler<TestQuery, String>>(
          TestQueryHandler.new,
        );

        final result = await dispatcher.dispatchQuery(TestQuery('test-data'));
        expect(result, 'result:test-data');
      },
    );

    test(
      'dispatchCommand successfully executes CommandHandler and emits events',
      () async {
        final log = <String>[];
        getIt.registerFactory<CommandHandler<TestCommand, int>>(
          () => TestCommandHandler(dispatcher),
        );
        getIt.registerFactory<EventHandler<TestEvent>>(
          () => FirstEventHandler(log),
        );
        getIt.registerFactory<EventHandler<TestEvent>>(
          () => SecondEventHandler(log),
        );

        final result = await dispatcher.dispatchCommand(TestCommand(10));
        expect(result, 20);
        expect(log, unorderedEquals(['first:cmd:10', 'second:cmd:10']));
      },
    );

    test(
      'publishEvent completes without error when no handlers registered',
      () async {
        expect(dispatcher.publishEvent(UnregisteredEvent()), completes);
      },
    );
  });
}
