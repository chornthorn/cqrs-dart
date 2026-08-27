import 'package:injectable/injectable.dart';

@singleton
class AuthTokenStorage {
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  void saveToken(String token) => _token = token;
  void clear() => _token = null;
}
