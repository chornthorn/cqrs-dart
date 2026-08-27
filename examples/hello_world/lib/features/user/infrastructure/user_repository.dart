import 'package:hello_world/features/user/domain/entities/user.dart';
import 'package:injectable/injectable.dart';

@Injectable(scope: Scope.lazySingleton)
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
