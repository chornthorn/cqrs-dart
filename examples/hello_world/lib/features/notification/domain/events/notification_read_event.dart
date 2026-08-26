import 'package:cqrs/cqrs.dart';

class NotificationReadEvent extends Event {
  NotificationReadEvent({
    required this.notificationId,
    required this.recipientId,
  });

  final String notificationId;
  final String recipientId;
}
