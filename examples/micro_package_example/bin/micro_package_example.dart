import 'package:dio/dio.dart';
import 'package:micro_package_example/features/auth/auth_api_client.dart';
import 'package:micro_package_example/features/auth/auth_service.dart';
import 'package:micro_package_example/features/cart/cart_service.dart';
import 'package:micro_package_example/features/cart/checkout/checkout_service.dart';
import 'package:micro_package_example/features/cart/discount_calculator.dart';
import 'package:micro_package_example/features/catalog/catalog_api_client.dart';
import 'package:micro_package_example/features/catalog/product_repository.dart';
import 'package:micro_package_example/injection.dart';

void main() async {
  // ignore: avoid_print
  print('========================================================');
  // ignore: avoid_print
  print('🎯 Injectable Nested Micro-Package Demo');
  // ignore: avoid_print
  print('========================================================');

  // 1. Initialize Dependency Injection with auto-discovered micro-packages
  await configureDependencies();

  // 2. Demonstrate Dio injection
  final dio = getIt<Dio>();
  // ignore: avoid_print
  print('\n🌐 0. Injected Dio Instance (from @externalModule):');
  // ignore: avoid_print
  print('   Base URL: ${dio.options.baseUrl}');
  // ignore: avoid_print
  print('   Timeout:  ${dio.options.connectTimeout?.inSeconds}s');

  // 3. Resolve services from top-level micro-packages
  final authApiClient = getIt<AuthApiClient>();
  final catalogApiClient = getIt<CatalogApiClient>();
  final authService = getIt<AuthService>();
  final productRepo = getIt<ProductRepository>();
  final cartService = getIt<CartService>();

  // 4. Authenticate with Auth micro-package
  // ignore: avoid_print
  print('\n🔐 1. Auth Micro-Package (baseUrl: ${authApiClient.baseUrl}):');
  final loggedIn = await authService.login('alice@example.com', 'secret123');
  // ignore: avoid_print
  print('   User logged in: $loggedIn (Token: ${authService.currentToken})');

  // 5. Browse products from Catalog micro-package
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

  final discountCalc =
      getIt.get<DiscountCalculator>(param1: 15.0); // 15% discount
  final finalTotal = discountCalc.applyDiscount(subtotal);
  // ignore: avoid_print
  print('   Total after 15% discount: \$${finalTotal.toStringAsFixed(2)}');

  // 7. Resolve and execute from NESTED micro-package (features/cart/checkout)
  // ignore: avoid_print
  print('\n💳 4. Nested Micro-Package (features/cart/checkout):');
  final checkoutService = getIt<CheckoutService>();
  final orderSummary = await checkoutService.completeCheckout();
  if (orderSummary != null) {
    // ignore: avoid_print
    print('   🎉 Order Completed!');
    // ignore: avoid_print
    print('   Order ID:   ${orderSummary.orderId}');
    // ignore: avoid_print
    print('   Amount:     \$${orderSummary.totalAmount.toStringAsFixed(2)}');
    // ignore: avoid_print
    print('   Status:     ${orderSummary.status}');
    // ignore: avoid_print
    print('   Cart items remaining: ${cartService.items.length}');
  }

  // ignore: avoid_print
  print(
      '\n✅ Hierarchical nested micro-packages initialized and working perfectly!');
}
