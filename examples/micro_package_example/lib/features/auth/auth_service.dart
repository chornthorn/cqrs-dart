import 'package:injectable/injectable.dart';

import 'auth_api_client.dart';
import 'auth_repository.dart';
import 'auth_token_storage.dart';

@Injectable(scope: Scope.lazySingleton)
class AuthService {
  final AuthApiClient _apiClient;
  final AuthRepository _repository;
  final AuthTokenStorage _storage;

  AuthService(this._apiClient, this._repository, this._storage);

  String? get currentToken => _storage.token;

  Future<bool> login(String email, String password) async {
    final token = await _repository.authenticate(email, password);
    _storage.saveToken(token);
    return true;
  }

  void logout() {
    _storage.clear();
  }

  String get endpointUrl => _apiClient.baseUrl;
}
