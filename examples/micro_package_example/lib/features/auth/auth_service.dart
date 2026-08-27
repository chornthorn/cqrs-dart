import 'package:injectable/injectable.dart';

import 'auth_api_client.dart';
import 'auth_token_storage.dart';

@lazySingleton
class AuthService {
  final AuthApiClient _apiClient;
  final AuthTokenStorage _storage;

  AuthService(this._apiClient, this._storage);

  bool get isLoggedIn => _storage.isAuthenticated;
  String? get currentToken => _storage.token;

  Future<bool> login(String email, String password) async {
    final token = await _apiClient.login(email, password);
    if (token != null) {
      _storage.saveToken(token);
      return true;
    }
    return false;
  }

  void logout() => _storage.clear();
}
