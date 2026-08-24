import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart';
import 'package:hello_world/features/notification/infrastructure/notification_log.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: EventHandler<NotificationSentEvent>)
class PushNotificationDeliveryHandler
    implements EventHandler<NotificationSentEvent> {
  PushNotificationDeliveryHandler(this._log);

  final NotificationLog _log;

  @override
  Future<void> handle(NotificationSentEvent event) async {
    print('🔔 Dispatching push notification to device: ${event.title}');
    _log.record('push:${event.recipientId}:${event.notificationId}');
  }
}
