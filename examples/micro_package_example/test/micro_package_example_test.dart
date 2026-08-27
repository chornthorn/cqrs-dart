import 'package:dio/dio.dart';
import 'package:micro_package_example/features/auth/auth_api_client.dart';
import 'package:micro_package_example/features/auth/auth_service.dart';
import 'package:micro_package_example/features/auth/auth_token_storage.dart';
import 'package:micro_package_example/features/cart/cart_service.dart';
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

  test('registers and resolves Dio and dependencies from all micro-packages',
      () {
    expect(getIt.isRegistered<Dio>(), isTrue);
    expect(getIt<Dio>().options.baseUrl, 'https://api.example.com');
    expect(getIt.isRegistered<AuthTokenStorage>(), isTrue);
    expect(getIt.isRegistered<AuthApiClient>(), isTrue);
    expect(getIt.isRegistered<CatalogApiClient>(), isTrue);
    expect(getIt.isRegistered<AuthService>(), isTrue);
    expect(getIt.isRegistered<ProductRepository>(), isTrue);
    expect(getIt.isRegistered<CartService>(), isTrue);
    expect(getIt.isRegistered<DiscountCalculator>(), isTrue);
  });

  test('injected Dio is shared across services', () {
    final dio = getIt<Dio>();
    final authApi = getIt<AuthApiClient>();
    final catalogApi = getIt<CatalogApiClient>();

    expect(authApi.baseUrl, equals(dio.options.baseUrl));
    expect(catalogApi.endpointUrl, contains(dio.options.baseUrl));
  });

  test('executes auth flow with singleton state', () async {
    final authService = getIt<AuthService>();
    expect(authService.isLoggedIn, isFalse);

    final ok = await authService.login('alice@example.com', 'secret123');
    expect(ok, isTrue);
    expect(authService.isLoggedIn, isTrue);

    final tokenStorage = getIt<AuthTokenStorage>();
    expect(tokenStorage.token, contains('alice@example.com'));
  });

  test('calculates cart totals and applies discount via factory with param',
      () {
    final cart = getIt<CartService>();
    cart.addItem(
        productId: '1', title: 'Item 1', unitPrice: 100.0, quantity: 2);
    expect(cart.subtotal, 200.0);

    final discountCalc = getIt.get<DiscountCalculator>(param1: 20.0);
    final discounted = discountCalc.applyDiscount(cart.subtotal);
    expect(discounted, 160.0);
  });
}
