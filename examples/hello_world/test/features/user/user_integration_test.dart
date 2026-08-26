import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/user/user.dart';
import 'package:hello_world/injection.dart';
import 'package:test/test.dart';

class UnusedEvent extends Event {}

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'command creates a user and notifies every event handler',
    () async {
      final created = await getIt<CqrsDispatcher>().command(
        CreateUserCommand('test@example.com'),
      );

      expect(created, isTrue);
      expect(
        getIt<SideEffectLog>().entries,
        unorderedEquals(['welcome:USER-123', 'analytics:USER-123']),
      );
    },
  );

  test('query returns the user written by the command', () async {
    await getIt<CqrsDispatcher>().command(
      CreateUserCommand('test@example.com'),
    );
    final user = await getIt<CqrsDispatcher>().query(
      GetUserQuery('USER-123'),
    );

    expect(user, isNotNull);
    expect(user!.id, 'USER-123');
    expect(user.email, 'test@example.com');
  });

  test('query returns null when the user does not exist', () async {
    final user = await getIt<CqrsDispatcher>().query(
      GetUserQuery('missing'),
    );

    expect(user, isNull);
  });

  test('publish is a no-op when no handlers are registered', () async {
    await getIt<CqrsDispatcher>().publish(UnusedEvent());
  });
}
