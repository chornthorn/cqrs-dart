import 'package:hello_world/features/notification/application/queries/get_notifications_query.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:test/test.dart';

void main() {
  group('GetNotificationsHandler', () {
    late NotificationRepository repository;
    late GetNotificationsHandler handler;

    setUp(() {
      repository = NotificationRepository();
      handler = GetNotificationsHandler(repository);
    });

    test('returns notifications belonging to specified recipient', () async {
      repository.create(recipientId: 'USER-1', title: 'T1', message: 'M1');
      repository.create(recipientId: 'USER-2', title: 'T2', message: 'M2');
      repository.create(recipientId: 'USER-1', title: 'T3', message: 'M3');

      final result = await handler.execute(GetNotificationsQuery('USER-1'));
      expect(result.length, 2);
      expect(result.map((n) => n.title), ['T1', 'T3']);
    });
  });
}
