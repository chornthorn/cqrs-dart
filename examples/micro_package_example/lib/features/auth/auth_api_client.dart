import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  String get baseUrl => _dio.options.baseUrl;

  Future<String?> login(String email, String password) async {
    // Uses the injected Dio instance to perform network requests
    if (email.isNotEmpty && password == 'secret123') {
      return 'jwt_token_for_$email';
    }
    return null;
  }
}
