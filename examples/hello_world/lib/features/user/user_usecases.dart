import 'package:injectable/injectable.dart';

import 'package:dart_cqrs/dart_cqrs.dart';

class User {
  const User({required this.id, required this.email});

  final String id;
  final String email;
}

class CreateUserCommand extends Command<bool> {
  CreateUserCommand(this.email);

  final String email;
}

class GetUserQuery extends Query<User?> {
  GetUserQuery(this.userId);

  final String userId;
}

class UserCreatedEvent extends DomainEvent {
  UserCreatedEvent(this.userId);

  final String userId;
}

@lazySingleton
class UserRepository {
  final Map<String, User> _users = {};
  int _nextId = 123;

  User create({required String email}) {
    final user = User(id: 'USER-$_nextId', email: email);
    _nextId += 1;
    _users[user.id] = user;
    return user;
  }

  User? findById(String userId) => _users[userId];
}

@lazySingleton
class SideEffectLog {
  final List<String> entries = [];

  void record(String entry) => entries.add(entry);
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

@Injectable(as: QueryHandler<GetUserQuery, User?>)
class GetUserHandler implements QueryHandler<GetUserQuery, User?> {
  GetUserHandler(this._users);

  final UserRepository _users;

  @override
  Future<User?> execute(GetUserQuery query) async {
    return _users.findById(query.userId);
  }
}

@Injectable(as: EventHandler<UserCreatedEvent>)
class WelcomeEmailHandler implements EventHandler<UserCreatedEvent> {
  WelcomeEmailHandler(this._log);

  final SideEffectLog _log;

  @override
  Future<void> handle(UserCreatedEvent event) async {
    print('📨 Sending welcome email to ${event.userId}');
    _log.record('welcome:${event.userId}');
  }
}

@Injectable(as: EventHandler<UserCreatedEvent>)
class AnalyticsHandler implements EventHandler<UserCreatedEvent> {
  AnalyticsHandler(this._log);

  final SideEffectLog _log;

  @override
  Future<void> handle(UserCreatedEvent event) async {
    print('📊 Tracking analytics for new user ${event.userId}');
    _log.record('analytics:${event.userId}');
  }
}
