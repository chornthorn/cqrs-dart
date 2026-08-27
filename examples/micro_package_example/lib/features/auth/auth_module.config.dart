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
import 'package:micro_package_example/features/auth/auth_api_client.dart'
    as _i3;
import 'package:dio/src/dio.dart' as _i4;
import 'package:micro_package_example/features/auth/auth_repository.dart'
    as _i5;
import 'package:micro_package_example/features/auth/auth_service.dart' as _i6;
import 'package:micro_package_example/features/auth/auth_token_storage.dart'
    as _i7;

class AuthInjectableModule extends _i1.MicroPackageModule {
  @override
  void init(_i1.GetItHelper gh) {
    gh.factory<_i3.AuthApiClient>(() => _i3.AuthApiClient(gh<_i4.Dio>()));
    gh.lazySingleton<_i5.AuthRepository>(() => _i5.AuthRepository());
    gh.lazySingleton<_i6.AuthService>(
      () =>
          _i6.AuthService(gh<_i3.AuthApiClient>(), gh<_i7.AuthTokenStorage>()),
    );
    gh.singleton<_i7.AuthTokenStorage>(_i7.AuthTokenStorage());
  }
}

extension AuthInjectableModuleX on _i2.GetIt {
  _i2.GetIt init({
    String? environment,
    _i1.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i1.GetItHelper(
      this,
      environment: environment,
      environmentFilter: environmentFilter,
    );
    AuthInjectableModule().init(gh);
    return this;
  }
}
