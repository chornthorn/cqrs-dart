import 'package:cqrs/cqrs.dart';

class NotificationSentEvent extends Event {
  NotificationSentEvent({
    required this.notificationId,
    required this.title,
    required this.recipientId,
  });

  final String notificationId;
  final String title;
  final String recipientId;
}
