import 'package:dio/dio.dart';
import 'package:micro_package_example/features/auth/auth_service.dart';
import 'package:micro_package_example/features/cart/cart_service.dart';
import 'package:micro_package_example/features/cart/checkout/checkout_service.dart';
import 'package:micro_package_example/features/cart/checkout/payment_gateway.dart';
import 'package:micro_package_example/features/cart/discount_calculator.dart';
import 'package:micro_package_example/features/catalog/catalog_api_client.dart';
import 'package:micro_package_example/features/catalog/product_repository.dart';
import 'package:micro_package_example/injection.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  test('registers and resolves Dio and dependencies from all micro-packages', () {
    expect(getIt.isRegistered<Dio>(), isTrue);
    expect(getIt.isRegistered<AuthService>(), isTrue);
    expect(getIt.isRegistered<ProductRepository>(), isTrue);
    expect(getIt.isRegistered<CartService>(), isTrue);
    expect(getIt.isRegistered<PaymentGateway>(), isTrue);
    expect(getIt.isRegistered<CheckoutService>(), isTrue);
  });

  test('resolves and executes nested checkout micro-package', () async {
    final cartService = getIt<CartService>();
    final checkoutService = getIt<CheckoutService>();

    cartService.addItem(
      productId: 'item-1',
      title: 'Domain-Driven Design',
      unitPrice: 50.0,
      quantity: 2,
    );

    expect(cartService.subtotal, 100.0);

    final summary = await checkoutService.completeCheckout();
    expect(summary, isNotNull);
    expect(summary!.totalAmount, 100.0);
    expect(summary.status, 'PAID');
    expect(cartService.items, isEmpty);
  });

  test('injected Dio is shared across services', () {
    final catalogApi = getIt<CatalogApiClient>();
    expect(catalogApi.endpointUrl, 'https://api.example.com/products');
  });

  test('calculates cart totals and applies discount via factory with param', () {
    final discount = getIt.get<DiscountCalculator>(param1: 20.0);
    expect(discount.applyDiscount(100.0), 80.0);
  });
}
