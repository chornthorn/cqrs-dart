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
import 'package:micro_package_example/features/auth/auth_module.config.dart'
    as _i3;
import 'package:micro_package_example/features/cart/cart_module.config.dart'
    as _i4;
import 'package:micro_package_example/features/cart/checkout/checkout_module.config.dart'
    as _i5;
import 'package:micro_package_example/features/catalog/catalog_module.config.dart'
    as _i6;
import 'package:micro_package_example/core/third_party_module.dart' as _i7;
import 'package:dio/src/dio.dart' as _i8;

extension GetItInjectableX on _i2.GetIt {
  _i2.GetIt init({
    String? environment,
    _i1.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i1.GetItHelper(
      this,
      environment: environment,
      environmentFilter: environmentFilter,
    );
    gh.initMicroPackage(_i3.AuthInjectableModule());
    gh.initMicroPackage(_i4.CartInjectableModule());
    gh.initMicroPackage(_i5.CheckoutInjectableModule());
    gh.initMicroPackage(_i6.CatalogInjectableModule());
    final thirdPartyModule = _$ThirdPartyModule();
    gh.factory<String>(() => thirdPartyModule.baseUrl, instanceName: 'baseUrl');
    gh.lazySingleton<_i8.Dio>(
      () => thirdPartyModule.dio(gh<String>(instanceName: 'baseUrl')),
    );
    return this;
  }
}

class _$ThirdPartyModule extends _i7.ThirdPartyModule {}
