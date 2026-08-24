import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationReadEvent', () {
    test('instantiates with read event details', () {
      final event = NotificationReadEvent(
        notificationId: 'NOTIF-1',
        recipientId: 'USER-1',
      );

      expect(event.notificationId, 'NOTIF-1');
      expect(event.recipientId, 'USER-1');
    });
  });
}
