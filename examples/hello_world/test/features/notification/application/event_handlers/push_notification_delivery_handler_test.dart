import 'package:hello_world/features/notification/application/event_handlers/push_notification_delivery_handler.dart';
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_log.dart';
import 'package:test/test.dart';

void main() {
  group('PushNotificationDeliveryHandler', () {
    test('records push notification into log', () async {
      final log = NotificationLog();
      final handler = PushNotificationDeliveryHandler(log);

      await handler.handle(
        NotificationSentEvent(
          notificationId: 'NOTIF-1',
          recipientId: 'USER-1',
          title: 'Hello',
        ),
      );

      expect(log.entries, ['push:USER-1:NOTIF-1']);
    });
  });
}
