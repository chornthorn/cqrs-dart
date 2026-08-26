import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/notification.dart';
import 'package:hello_world/features/user/user.dart';
import 'package:hello_world/injection.dart';

void main() async {
  await configureDependencies();

  final dispatcher = getIt<CqrsDispatcher>();

  print('--- App Started ---');

  // 1. User Feature: Command & Query
  await dispatcher.command(CreateUserCommand('test@example.com'));
  final user = await dispatcher.query(GetUserQuery('USER-123'));
  print('Queried user: ${user?.email}');

  // 2. Notification Feature: Command & Query
  final notifId = await dispatcher.command(
    SendNotificationCommand(
      recipientId: 'USER-123',
      title: 'Welcome to dart_cqrs!',
      message: 'Explore commands, queries, and events.',
    ),
  );

  final notifications = await dispatcher.query(
    GetNotificationsQuery('USER-123'),
  );
  print('Total notifications: ${notifications.length}');

  await dispatcher.command(MarkNotificationAsReadCommand(notifId));
  final unreadCount = await dispatcher.query(
    GetUnreadNotificationCountQuery('USER-123'),
  );
  print('Unread notifications remaining: $unreadCount');
}
