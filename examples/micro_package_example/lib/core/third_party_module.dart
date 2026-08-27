import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@thirdParty
abstract class ThirdPartyModule {
  @Inject('baseUrl')
  String get baseUrl => 'https://api.example.com';

  @Injectable(scope: Scope.lazySingleton)
  Dio dio(@Inject('baseUrl') String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Accept': 'application/json'},
      ),
    );
  }
}
