import 'package:hello_world/features/user/infrastructure/user_repository.dart';
import 'package:test/test.dart';

void main() {
  group('UserRepository', () {
    late UserRepository repository;

    setUp(() {
      repository = UserRepository();
    });

    test('creates user with auto-incremented ID', () {
      final user1 = repository.create(email: 'user1@example.com');
      final user2 = repository.create(email: 'user2@example.com');

      expect(user1.id, 'USER-123');
      expect(user1.email, 'user1@example.com');
      expect(user2.id, 'USER-124');
      expect(user2.email, 'user2@example.com');
    });

    test('findById returns user when exists, null otherwise', () {
      final created = repository.create(email: 'test@example.com');
      expect(repository.findById(created.id)?.email, 'test@example.com');
      expect(repository.findById('non-existent'), isNull);
    });
  });
}
