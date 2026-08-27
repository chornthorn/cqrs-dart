import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRepository {
  final Map<String, String> _users = {'alice@example.com': 'Alice User'};

  Future<String?> authenticate(String email, String password) async {
    if (password == 'secret123' && _users.containsKey(email)) {
      return 'user_001';
    }
    return null;
  }
}
