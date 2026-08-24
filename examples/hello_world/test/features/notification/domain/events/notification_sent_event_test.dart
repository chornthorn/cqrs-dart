import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationSentEvent', () {
    test('instantiates with notification details', () {
      final event = NotificationSentEvent(
        notificationId: 'NOTIF-1',
        recipientId: 'USER-1',
        title: 'Alert',
      );

      expect(event.notificationId, 'NOTIF-1');
      expect(event.recipientId, 'USER-1');
      expect(event.title, 'Alert');
    });
  });
}
