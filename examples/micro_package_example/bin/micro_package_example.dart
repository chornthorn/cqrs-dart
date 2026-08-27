import 'package:dio/dio.dart';
import 'package:micro_package_example/features/auth/auth_api_client.dart';
import 'package:micro_package_example/features/auth/auth_service.dart';
import 'package:micro_package_example/features/cart/cart_service.dart';
import 'package:micro_package_example/features/cart/discount_calculator.dart';
import 'package:micro_package_example/features/catalog/catalog_api_client.dart';
import 'package:micro_package_example/features/catalog/product_repository.dart';
import 'package:micro_package_example/injection.dart';

void main() async {
  // ignore: avoid_print
  print('========================================================');
  // ignore: avoid_print
  print('🎯 Injectable Micro-Package App Demo (with Dio)');
  // ignore: avoid_print
  print('========================================================');

  // 1. Initialize Dependency Injection with auto-discovered micro-packages
  await configureDependencies();

  // 2. Demonstrate Dio injection
  final dio = getIt<Dio>();
  // ignore: avoid_print
  print('\n🌐 0. Injected Dio Instance:');
  // ignore: avoid_print
  print('   Base URL: ${dio.options.baseUrl}');
  // ignore: avoid_print
  print('   Timeout:  ${dio.options.connectTimeout?.inSeconds}s');
  // ignore: avoid_print
  print('   Headers:  ${dio.options.headers}');

  // 3. Resolve services from different folder-based micro-packages
  final authApiClient = getIt<AuthApiClient>();
  final catalogApiClient = getIt<CatalogApiClient>();
  final authService = getIt<AuthService>();
  final productRepo = getIt<ProductRepository>();
  final cartService = getIt<CartService>();

  // 4. Authenticate with Auth micro-package (uses injected Dio)
  // ignore: avoid_print
  print('\n🔐 1. Auth Micro-Package (Dio baseUrl: ${authApiClient.baseUrl}):');
  final loggedIn = await authService.login('alice@example.com', 'secret123');
  // ignore: avoid_print
  print('   User logged in: $loggedIn (Token: ${authService.currentToken})');

  // 5. Browse products from Catalog micro-package (uses injected Dio)
  // ignore: avoid_print
  print('\n📦 2. Catalog Micro-Package (endpoint: ${catalogApiClient.endpointUrl}):');
  final products = productRepo.listAll();
  for (final item in products) {
    // ignore: avoid_print
    print(
        '   - [${item.id}] ${item.title} -> \$${item.price.toStringAsFixed(2)}');
  }

  // 6. Add products to cart via Cart micro-package
  // ignore: avoid_print
  print('\n🛒 3. Cart Micro-Package:');
  for (final product in products.take(2)) {
    cartService.addItem(
      productId: product.id,
      title: product.title,
      unitPrice: product.price,
      quantity: 1,
    );
    // ignore: avoid_print
    print('   Added to cart: ${product.title}');
  }

  final subtotal = cartService.subtotal;
  // ignore: avoid_print
  print('   Cart subtotal: \$${subtotal.toStringAsFixed(2)}');

  // 7. Use parameterized factory from Cart micro-package
  final discountCalc =
      getIt.get<DiscountCalculator>(param1: 15.0); // 15% discount
  final finalTotal = discountCalc.applyDiscount(subtotal);
  // ignore: avoid_print
  print('   Total after 15% discount: \$${finalTotal.toStringAsFixed(2)}');

  // ignore: avoid_print
  print(
      '\n✅ Dio injected and resolved seamlessly across all micro-packages!');
}
