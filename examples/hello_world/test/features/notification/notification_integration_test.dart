import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/notification.dart';
import 'package:hello_world/injection.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'SendNotificationCommand creates notification and triggers event handler',
    () async {
      final dispatcher = getIt<CqrsDispatcher>();

      final notificationId = await dispatcher.command(
        SendNotificationCommand(
          recipientId: 'USER-123',
          title: 'Welcome!',
          message: 'Thanks for signing up.',
        ),
      );

      expect(notificationId, 'NOTIF-1');

      final log = getIt<NotificationLog>();
      expect(log.entries, contains('push:USER-123:NOTIF-1'));

      final notifications = await dispatcher.query(
        GetNotificationsQuery('USER-123'),
      );
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Welcome!');
      expect(notifications.first.isRead, isFalse);

      final unreadCount = await dispatcher.query(
        GetUnreadNotificationCountQuery('USER-123'),
      );
      expect(unreadCount, 1);
    },
  );

  test(
    'MarkNotificationAsReadCommand updates status and notifies event handler',
    () async {
      final dispatcher = getIt<CqrsDispatcher>();

      final notificationId = await dispatcher.command(
        SendNotificationCommand(
          recipientId: 'USER-456',
          title: 'Security Alert',
          message: 'New login detected.',
        ),
      );

      final success = await dispatcher.command(
        MarkNotificationAsReadCommand(notificationId),
      );
      expect(success, isTrue);

      final log = getIt<NotificationLog>();
      expect(log.entries, contains('read:USER-456:$notificationId'));

      final unreadCount = await dispatcher.query(
        GetUnreadNotificationCountQuery('USER-456'),
      );
      expect(unreadCount, 0);
    },
  );
}
