import 'package:hello_world/features/user/domain/entities/user.dart';
import 'package:test/test.dart';

void main() {
  group('User Entity', () {
    test('instantiates with id and email correctly', () {
      const user = User(id: 'USER-123', email: 'alice@example.com');
      expect(user.id, 'USER-123');
      expect(user.email, 'alice@example.com');
    });
  });
}
