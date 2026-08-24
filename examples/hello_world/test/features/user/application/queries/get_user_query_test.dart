import 'package:hello_world/features/user/application/queries/get_user_query.dart';
import 'package:hello_world/features/user/infrastructure/user_repository.dart';
import 'package:test/test.dart';

void main() {
  group('GetUserHandler', () {
    late UserRepository repository;
    late GetUserHandler handler;

    setUp(() {
      repository = UserRepository();
      handler = GetUserHandler(repository);
    });

    test('returns user when found in repository', () async {
      final user = repository.create(email: 'user@example.com');
      final result = await handler.execute(GetUserQuery(user.id));

      expect(result, isNotNull);
      expect(result!.id, user.id);
      expect(result.email, 'user@example.com');
    });

    test('returns null when user not found', () async {
      final result = await handler.execute(GetUserQuery('non-existent'));
      expect(result, isNull);
    });
  });
}
