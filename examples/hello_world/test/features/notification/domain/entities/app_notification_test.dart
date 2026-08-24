import 'package:hello_world/features/notification/domain/entities/app_notification.dart';
import 'package:test/test.dart';

void main() {
  group('AppNotification Entity', () {
    test('instantiates with proper default values', () {
      const notif = AppNotification(
        id: 'NOTIF-1',
        recipientId: 'USER-1',
        title: 'Title',
        message: 'Message',
      );

      expect(notif.id, 'NOTIF-1');
      expect(notif.recipientId, 'USER-1');
      expect(notif.title, 'Title');
      expect(notif.message, 'Message');
      expect(notif.isRead, isFalse);
    });

    test('copyWith updates isRead state correctly', () {
      const notif = AppNotification(
        id: 'NOTIF-1',
        recipientId: 'USER-1',
        title: 'Title',
        message: 'Message',
      );

      final updated = notif.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 'NOTIF-1');
      expect(updated.recipientId, 'USER-1');
    });
  });
}
