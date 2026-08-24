import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationRepository', () {
    late NotificationRepository repository;

    setUp(() {
      repository = NotificationRepository();
    });

    test('creates and retrieves notifications with auto-increment ID', () {
      final notif1 = repository.create(
        recipientId: 'USER-1',
        title: 'Title 1',
        message: 'Message 1',
      );
      final notif2 = repository.create(
        recipientId: 'USER-1',
        title: 'Title 2',
        message: 'Message 2',
      );

      expect(notif1.id, 'NOTIF-1');
      expect(notif2.id, 'NOTIF-2');

      final found = repository.findById('NOTIF-1');
      expect(found, isNotNull);
      expect(found!.title, 'Title 1');
    });

    test('findByRecipient returns all notifications for a recipient', () {
      repository.create(recipientId: 'USER-1', title: 'T1', message: 'M1');
      repository.create(recipientId: 'USER-2', title: 'T2', message: 'M2');
      repository.create(recipientId: 'USER-1', title: 'T3', message: 'M3');

      final user1Notifs = repository.findByRecipient('USER-1');
      expect(user1Notifs.length, 2);

      final user2Notifs = repository.findByRecipient('USER-2');
      expect(user2Notifs.length, 1);
    });

    test('markAsRead updates isRead to true and countUnread decreases', () {
      final notif = repository.create(
        recipientId: 'USER-1',
        title: 'T1',
        message: 'M1',
      );

      expect(repository.countUnread('USER-1'), 1);

      final success = repository.markAsRead(notif.id);
      expect(success, isTrue);

      expect(repository.findById(notif.id)?.isRead, isTrue);
      expect(repository.countUnread('USER-1'), 0);
    });

    test('markAsRead returns false for non-existent notification', () {
      expect(repository.markAsRead('invalid-id'), isFalse);
    });
  });
}
