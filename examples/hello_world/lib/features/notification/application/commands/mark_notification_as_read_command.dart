import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:injectable/injectable.dart';

class MarkNotificationAsReadCommand extends Command<bool> {
  MarkNotificationAsReadCommand(this.notificationId);

  final String notificationId;
}

@injectable
class MarkNotificationAsReadHandler
    implements CommandHandler<MarkNotificationAsReadCommand, bool> {
  MarkNotificationAsReadHandler(this._dispatcher, this._notifications);

  final CqrsDispatcher _dispatcher;
  final NotificationRepository _notifications;

  @override
  Future<bool> execute(MarkNotificationAsReadCommand command) async {
    final existing = _notifications.findById(command.notificationId);
    if (existing == null) return false;

    final success = _notifications.markAsRead(command.notificationId);
    if (success) {
      await _dispatcher.publish(
        NotificationReadEvent(
          notificationId: command.notificationId,
          recipientId: existing.recipientId,
        ),
      );
    }
    return success;
  }
}
