import 'package:injectable/injectable.dart';
import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';

class MarkNotificationAsReadCommand extends Command<bool> {
  MarkNotificationAsReadCommand(this.notificationId);

  final String notificationId;
}

@Injectable(as: CommandHandler<MarkNotificationAsReadCommand, bool>)
class MarkNotificationAsReadHandler
    implements CommandHandler<MarkNotificationAsReadCommand, bool> {
  MarkNotificationAsReadHandler(this._dispatcher, this._repository);

  final CqrsDispatcher _dispatcher;
  final NotificationRepository _repository;

  @override
  Future<bool> execute(MarkNotificationAsReadCommand command) async {
    final updated = _repository.markAsRead(command.notificationId);
    if (updated) {
      final notif = _repository.findById(command.notificationId)!;
      await _dispatcher.publishEvent(
        NotificationReadEvent(
          notificationId: notif.id,
          recipientId: notif.recipientId,
        ),
      );
    }
    return updated;
  }
}
