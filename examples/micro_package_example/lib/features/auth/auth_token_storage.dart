import 'package:injectable/injectable.dart';

@Injectable(scope: Scope.singleton)
class AuthTokenStorage {
  String? _token;

  String? get token => _token;

  void saveToken(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
