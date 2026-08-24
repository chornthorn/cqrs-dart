class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    this.isRead = false,
  });

  final String id;
  final String recipientId;
  final String title;
  final String message;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      recipientId: recipientId,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
    );
  }
}
