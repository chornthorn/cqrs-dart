import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/notification/application/commands/mark_notification_as_read_command.dart';
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:test/test.dart';

class MockDispatcher extends CqrsDispatcher {
  final List<DomainEvent> publishedEvents = [];

  @override
  Future<void> publishEvent<TEvent extends DomainEvent>(TEvent event) async {
    publishedEvents.add(event);
  }
}

void main() {
  group('MarkNotificationAsReadHandler', () {
    late NotificationRepository repository;
    late MockDispatcher mockDispatcher;
    late MarkNotificationAsReadHandler handler;

    setUp(() {
      repository = NotificationRepository();
      mockDispatcher = MockDispatcher();
      handler = MarkNotificationAsReadHandler(mockDispatcher, repository);
    });

    test(
      'marks existing notification as read and emits NotificationReadEvent',
      () async {
        final notif = repository.create(
          recipientId: 'USER-1',
          title: 'Title',
          message: 'Message',
        );

        final result = await handler.execute(
          MarkNotificationAsReadCommand(notif.id),
        );

        expect(result, isTrue);
        expect(repository.findById(notif.id)?.isRead, isTrue);

        expect(mockDispatcher.publishedEvents.length, 1);
        final event =
            mockDispatcher.publishedEvents.first as NotificationReadEvent;
        expect(event.notificationId, notif.id);
        expect(event.recipientId, 'USER-1');
      },
    );

    test(
      'returns false when notification does not exist and does not emit event',
      () async {
        final result = await handler.execute(
          MarkNotificationAsReadCommand('invalid-id'),
        );

        expect(result, isFalse);
        expect(mockDispatcher.publishedEvents, isEmpty);
      },
    );
  });
}
