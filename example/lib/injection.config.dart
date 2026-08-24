// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dart_cqrs/dart_cqrs.dart' as _i609;
import 'package:dart_cqrs_example/features/user/user_usecases.dart' as _i178;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> bootstrap({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    this.enableRegisteringMultipleInstancesOfOneType();
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i609.DartCqrsPackageModule().init(gh);
    gh.lazySingleton<_i178.UserRepository>(() => _i178.UserRepository());
    gh.lazySingleton<_i178.SideEffectLog>(() => _i178.SideEffectLog());
    gh.factory<_i609.CommandHandler<_i178.CreateUserCommand, bool>>(
      () => _i178.CreateUserHandler(
        gh<_i609.CqrsDispatcher>(),
        gh<_i178.UserRepository>(),
      ),
    );
    gh.factory<_i609.QueryHandler<_i178.GetUserQuery, _i178.User?>>(
      () => _i178.GetUserHandler(gh<_i178.UserRepository>()),
    );
    gh.factory<_i609.EventHandler<_i178.UserCreatedEvent>>(
      () => _i178.WelcomeEmailHandler(gh<_i178.SideEffectLog>()),
    );
    gh.factory<_i609.EventHandler<_i178.UserCreatedEvent>>(
      () => _i178.AnalyticsHandler(gh<_i178.SideEffectLog>()),
    );
    return this;
  }
}
