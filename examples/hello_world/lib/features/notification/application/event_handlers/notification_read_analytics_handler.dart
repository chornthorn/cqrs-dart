import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_log.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: EventHandler<NotificationReadEvent>)
class NotificationReadAnalyticsHandler
    implements EventHandler<NotificationReadEvent> {
  NotificationReadAnalyticsHandler(this._log);

  final NotificationLog _log;

  @override
  Future<void> handle(NotificationReadEvent event) async {
    print('📊 Analytics: Notification ${event.notificationId} read');
    _log.record('read:${event.recipientId}:${event.notificationId}');
  }
}
