import 'package:hello_world/features/notification/domain/entities/app_notification.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationRepository {
  final Map<String, AppNotification> _notifications = {};
  int _nextId = 1;

  AppNotification create({
    required String recipientId,
    required String title,
    required String message,
  }) {
    final notification = AppNotification(
      id: 'NOTIF-$_nextId',
      recipientId: recipientId,
      title: title,
      message: message,
    );
    _nextId += 1;
    _notifications[notification.id] = notification;
    return notification;
  }

  bool markAsRead(String id) {
    final current = _notifications[id];
    if (current == null) return false;
    _notifications[id] = current.copyWith(isRead: true);
    return true;
  }

  AppNotification? findById(String id) => _notifications[id];

  List<AppNotification> findByRecipient(String recipientId) {
    return _notifications.values
        .where((n) => n.recipientId == recipientId)
        .toList();
  }

  int countUnread(String recipientId) {
    return _notifications.values
        .where((n) => n.recipientId == recipientId && !n.isRead)
        .length;
  }
}
