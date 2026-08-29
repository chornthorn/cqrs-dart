import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/user/domain/entities/user.dart';
import 'package:hello_world/features/user/infrastructure/user_repository.dart';
import 'package:injectable/injectable.dart';

class GetUserQuery extends Query<User?> {
  GetUserQuery(this.userId);

  final String userId;
}

@Injectable()
class GetUserHandler implements QueryHandler<GetUserQuery, User?> {
  GetUserHandler(this._users);

  final UserRepository _users;

  @override
  Future<User?> execute(GetUserQuery query) async {
    return _users.findById(query.userId);
  }
}
