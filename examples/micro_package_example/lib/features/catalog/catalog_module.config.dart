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
import 'package:micro_package_example/features/catalog/catalog_api_client.dart'
    as _i3;
import 'package:dio/src/dio.dart' as _i4;
import 'package:micro_package_example/features/catalog/product_repository.dart'
    as _i5;

class CatalogInjectableModule extends _i1.MicroPackageModule {
  @override
  void init(_i1.GetItHelper gh) {
    gh.factory<_i3.CatalogApiClient>(() => _i3.CatalogApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i5.ProductRepository>(
      () => _i5.ProductRepository(gh<_i3.CatalogApiClient>()),
    );
  }
}

extension CatalogInjectableModuleX on _i2.GetIt {
  _i2.GetIt init({
    String? environment,
    _i1.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i1.GetItHelper(
      this,
      environment: environment,
      environmentFilter: environmentFilter,
    );
    CatalogInjectableModule().init(gh);
    return this;
  }
}
