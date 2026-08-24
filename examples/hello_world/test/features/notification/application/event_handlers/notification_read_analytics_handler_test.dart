import 'package:hello_world/features/notification/application/event_handlers/notification_read_analytics_handler.dart';
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_log.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationReadAnalyticsHandler', () {
    test('records read analytics event into log', () async {
      final log = NotificationLog();
      final handler = NotificationReadAnalyticsHandler(log);

      await handler.handle(
        NotificationReadEvent(notificationId: 'NOTIF-1', recipientId: 'USER-1'),
      );

      expect(log.entries, ['read:USER-1:NOTIF-1']);
    });
  });
}
