// dart format width=80

// **************************************************************************
// InjectableGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:injectable/injectable.dart' as _i1;
import 'package:get_it/get_it.dart' as _i2;
import 'package:micro_package_example/features/cart/cart_service.dart' as _i3;
import 'package:micro_package_example/features/cart/discount_calculator.dart'
    as _i4;

class CartInjectableModule extends _i1.MicroPackageModule {
  @override
  void init(_i1.GetItHelper gh) {
    gh.lazySingleton<_i3.CartService>(() => _i3.CartService());
    gh.factoryWithParam<_i4.DiscountCalculator, double, dynamic>(
      (discountRate, _) => _i4.DiscountCalculator(discountRate),
    );
  }
}

extension CartInjectableModuleX on _i2.GetIt {
  _i2.GetIt init({
    String? environment,
    _i1.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i1.GetItHelper(
      this,
      environment: environment,
      environmentFilter: environmentFilter,
    );
    CartInjectableModule().init(gh);
    return this;
  }
}
