import 'package:dart_cqrs/dart_cqrs.dart';

class NotificationSentEvent extends DomainEvent {
  NotificationSentEvent({
    required this.notificationId,
    required this.recipientId,
    required this.title,
  });

  final String notificationId;
  final String recipientId;
  final String title;
}
