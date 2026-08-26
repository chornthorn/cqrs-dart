import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_world/features/user/application/commands/create_user_command.dart';
import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:hello_world/features/user/infrastructure/user_repository.dart';
import 'package:test/test.dart';

final getIt = GetIt.instance;

class MockDispatcher extends DefaultCqrsDispatcher {
  final List<Event> publishedEvents = [];

  @override
  Future<void> publish<TEvent extends Event>(TEvent event) async {
    publishedEvents.add(event);
  }
}

void main() {
  group('CreateUserHandler', () {
    late UserRepository repository;
    late MockDispatcher mockDispatcher;
    late CreateUserHandler handler;

    setUp(() {
      repository = UserRepository();
      mockDispatcher = MockDispatcher();
      handler = CreateUserHandler(mockDispatcher, repository);
    });

    test('creates user in repository and publishes UserCreatedEvent', () async {
      final command = CreateUserCommand('user@example.com');
      final result = await handler.execute(command);

      expect(result, isTrue);

      final user = repository.findById('USER-123');
      expect(user, isNotNull);
      expect(user!.email, 'user@example.com');

      expect(mockDispatcher.publishedEvents.length, 1);
      final event = mockDispatcher.publishedEvents.first as UserCreatedEvent;
      expect(event.userId, 'USER-123');
    });
  });
}
