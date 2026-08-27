import 'package:injectable/injectable.dart';

import 'catalog_api_client.dart';
import 'models/product.dart';

@Injectable(scope: Scope.lazySingleton)
class ProductRepository {
  final CatalogApiClient _apiClient;

  ProductRepository(this._apiClient);

  List<Product> listAll() {
    return const [
      Product(id: 'book-1', title: 'Injectable for Dart', price: 29.99),
      Product(id: 'book-2', title: 'Micro-Packages in Action', price: 39.99),
      Product(id: 'book-3', title: 'Domain Driven Architecture', price: 49.99),
    ];
  }

  String get sourceApi => _apiClient.endpointUrl;
}
