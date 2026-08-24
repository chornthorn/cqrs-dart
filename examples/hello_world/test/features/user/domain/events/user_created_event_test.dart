import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:test/test.dart';

void main() {
  group('UserCreatedEvent', () {
    test('instantiates with userId', () {
      final event = UserCreatedEvent('USER-123');
      expect(event.userId, 'USER-123');
    });
  });
}
