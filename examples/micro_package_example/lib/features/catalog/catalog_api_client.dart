import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class CatalogApiClient {
  final Dio _dio;

  CatalogApiClient(this._dio);

  String get endpointUrl => '${_dio.options.baseUrl}/products';
}
