import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/user/user_usecases.dart';
import 'package:hello_world/injection.dart';

void main() async {
  await configureDependencies();

  final dispatcher = getIt<CqrsDispatcher>();

  print('--- App Started ---');
  await dispatcher.dispatchCommand(CreateUserCommand('test@example.com'));

  final user = await dispatcher.dispatchQuery(GetUserQuery('USER-123'));
  print('Queried user: ${user?.email}');
}
