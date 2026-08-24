import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:hello_world/features/user/infrastructure/user_repository.dart';
import 'package:injectable/injectable.dart';

class CreateUserCommand extends Command<bool> {
  CreateUserCommand(this.email);

  final String email;
}

@Injectable(as: CommandHandler<CreateUserCommand, bool>)
class CreateUserHandler implements CommandHandler<CreateUserCommand, bool> {
  CreateUserHandler(this._dispatcher, this._users);

  final CqrsDispatcher _dispatcher;
  final UserRepository _users;

  @override
  Future<bool> execute(CreateUserCommand command) async {
    print('Database: Creating user ${command.email}');
    final user = _users.create(email: command.email);
    await _dispatcher.publishEvent(UserCreatedEvent(user.id));
    return true;
  }
}
