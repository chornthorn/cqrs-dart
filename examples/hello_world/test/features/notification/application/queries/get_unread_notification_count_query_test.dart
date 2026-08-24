import 'package:hello_world/features/notification/application/queries/get_unread_notification_count_query.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:test/test.dart';

void main() {
  group('GetUnreadNotificationCountHandler', () {
    late NotificationRepository repository;
    late GetUnreadNotificationCountHandler handler;

    setUp(() {
      repository = NotificationRepository();
      handler = GetUnreadNotificationCountHandler(repository);
    });

    test('returns unread count accurately', () async {
      final notif1 = repository.create(
        recipientId: 'USER-1',
        title: 'T1',
        message: 'M1',
      );
      repository.create(recipientId: 'USER-1', title: 'T2', message: 'M2');

      expect(
        await handler.execute(GetUnreadNotificationCountQuery('USER-1')),
        2,
      );

      repository.markAsRead(notif1.id);

      expect(
        await handler.execute(GetUnreadNotificationCountQuery('USER-1')),
        1,
      );
    });
  });
}
