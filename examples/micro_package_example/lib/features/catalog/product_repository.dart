import 'package:injectable/injectable.dart';

import 'catalog_api_client.dart';
import 'models/product.dart';

@lazySingleton
class ProductRepository {
  // ignore: unused_field
  final CatalogApiClient _apiClient;

  ProductRepository(this._apiClient);

  final List<Product> _items = const [
    Product(id: 'book-1', title: 'Injectable for Dart', price: 29.99),
    Product(id: 'book-2', title: 'Micro-Packages in Action', price: 39.99),
    Product(id: 'book-3', title: 'Domain Driven Architecture', price: 49.99),
  ];

  List<Product> listAll() => _items;
  Product? findById(String id) => _items.where((p) => p.id == id).firstOrNull;
}
