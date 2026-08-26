import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/application/commands/send_notification_command.dart';
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:test/test.dart';

class MockDispatcher extends DefaultCqrsDispatcher {
  final List<DomainEvent> publishedEvents = [];

  @override
  Future<void> publish<TEvent extends DomainEvent>(TEvent event) async {
    publishedEvents.add(event);
  }
}

void main() {
  group('SendNotificationHandler', () {
    late NotificationRepository repository;
    late MockDispatcher mockDispatcher;
    late SendNotificationHandler handler;

    setUp(() {
      repository = NotificationRepository();
      mockDispatcher = MockDispatcher();
      handler = SendNotificationHandler(mockDispatcher, repository);
    });

    test('creates notification and emits NotificationSentEvent', () async {
      final command = SendNotificationCommand(
        recipientId: 'USER-1',
        title: 'New Message',
        message: 'You got mail',
      );

      final notifId = await handler.execute(command);
      expect(notifId, 'NOTIF-1');

      final notif = repository.findById('NOTIF-1');
      expect(notif, isNotNull);
      expect(notif!.title, 'New Message');

      expect(mockDispatcher.publishedEvents.length, 1);
      final event = mockDispatcher.publishedEvents.first as NotificationSentEvent;
      expect(event.notificationId, 'NOTIF-1');
      expect(event.recipientId, 'USER-1');
      expect(event.title, 'New Message');
    });
  });
}
