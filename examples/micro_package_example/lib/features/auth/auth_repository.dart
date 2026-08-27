import 'package:injectable/injectable.dart';

@Injectable(scope: Scope.lazySingleton)
class AuthRepository {
  Future<String> authenticate(String email, String password) async {
    // Simulated remote authentication
    return 'jwt_token_for_$email';
  }
}
