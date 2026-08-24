import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:injectable/injectable.dart';

class SendNotificationCommand extends Command<String> {
  SendNotificationCommand({
    required this.recipientId,
    required this.title,
    required this.message,
  });

  final String recipientId;
  final String title;
  final String message;
}

@Injectable(as: CommandHandler<SendNotificationCommand, String>)
class SendNotificationHandler
    implements CommandHandler<SendNotificationCommand, String> {
  SendNotificationHandler(this._dispatcher, this._repository);

  final CqrsDispatcher _dispatcher;
  final NotificationRepository _repository;

  @override
  Future<String> execute(SendNotificationCommand command) async {
    print('NotificationService: Creating notification "${command.title}"');
    final notification = _repository.create(
      recipientId: command.recipientId,
      title: command.title,
      message: command.message,
    );

    await _dispatcher.publishEvent(
      NotificationSentEvent(
        notificationId: notification.id,
        recipientId: notification.recipientId,
        title: notification.title,
      ),
    );

    return notification.id;
  }
}
