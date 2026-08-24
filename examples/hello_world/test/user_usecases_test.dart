import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/user/user_usecases.dart';
import 'package:hello_world/injection.dart';
import 'package:test/test.dart';

class UnusedEvent extends DomainEvent {}

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'dispatchCommand creates a user and notifies every event handler',
    () async {
      final created = await getIt<CqrsDispatcher>().dispatchCommand(
        CreateUserCommand('test@example.com'),
      );

      expect(created, isTrue);
      expect(
        getIt<SideEffectLog>().entries,
        unorderedEquals(['welcome:USER-123', 'analytics:USER-123']),
      );
    },
  );

  test('dispatchQuery returns the user written by the command', () async {
    await getIt<CqrsDispatcher>().dispatchCommand(
      CreateUserCommand('test@example.com'),
    );
    final user = await getIt<CqrsDispatcher>().dispatchQuery(
      GetUserQuery('USER-123'),
    );

    expect(user, isNotNull);
    expect(user!.id, 'USER-123');
    expect(user.email, 'test@example.com');
  });

  test('dispatchQuery returns null when the user does not exist', () async {
    final user = await getIt<CqrsDispatcher>().dispatchQuery(
      GetUserQuery('missing'),
    );

    expect(user, isNull);
  });

  test('publishEvent is a no-op when no handlers are registered', () async {
    await getIt<CqrsDispatcher>().publishEvent(UnusedEvent());
  });
}
