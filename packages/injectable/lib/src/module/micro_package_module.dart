import 'dart:async';

import 'package:get_it/get_it.dart';

import 'environment_filter.dart';

/// Base class for modular micro-package dependency injection registration modules.
abstract class MicroPackageModule {
  const MicroPackageModule();

  /// Initializes dependencies in this module using the given [GetItHelper].
  FutureOr<void> init(GetItHelper gh);
}

/// Helper wrapper around [GetIt] to streamline dependency registration with environment filtering.
class GetItHelper {
  /// The underlying [GetIt] instance.
  final GetIt getIt;

  /// The environment filter used to selectively register dependencies.
  final EnvironmentFilter? environmentFilter;

  /// Optional active environment name string.
  final String? environment;

  /// Creates a [GetItHelper].
  GetItHelper(
    this.getIt, {
    this.environment,
    this.environmentFilter,
  });

  /// Resolves an instance of type [T] from the underlying [GetIt].
  T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
    Type? type,
  }) =>
      getIt.get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
        type: type,
      );

  /// Callable helper allowing `gh<T>()` syntax.
  T call<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
    Type? type,
  }) =>
      getIt.get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
        type: type,
      );

  bool _canRegister(Set<String>? envs) {
    if (envs == null || envs.isEmpty) return true;
    if (environmentFilter != null) {
      return environmentFilter!.canRegister(envs);
    }
    if (environment != null) {
      return envs.contains(environment);
    }
    return true;
  }

  /// Registers a factory dependency of type [T].
  void factory<T extends Object>(
    FactoryFunc<T> factoryFunc, {
    String? instanceName,
    Set<String>? registerFor,
  }) {
    if (_canRegister(registerFor)) {
      getIt.registerFactory<T>(factoryFunc, instanceName: instanceName);
    }
  }

  /// Registers a parameterized factory dependency of type [T] accepting [P1] and [P2].
  void factoryWithParam<T extends Object, P1, P2>(
    FactoryFuncParam<T, P1, P2> factoryFunc, {
    String? instanceName,
    Set<String>? registerFor,
  }) {
    if (_canRegister(registerFor)) {
      getIt.registerFactoryParam<T, P1, P2>(
        factoryFunc,
        instanceName: instanceName,
      );
    }
  }

  /// Registers a lazy singleton dependency of type [T].
  void lazySingleton<T extends Object>(
    FactoryFunc<T> factoryFunc, {
    String? instanceName,
    DisposingFunc<T>? dispose,
    Set<String>? registerFor,
  }) {
    if (_canRegister(registerFor)) {
      getIt.registerLazySingleton<T>(
        factoryFunc,
        instanceName: instanceName,
        dispose: dispose,
      );
    }
  }

  /// Registers an eager singleton dependency of type [T].
  T singleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
    Set<String>? registerFor,
  }) {
    if (_canRegister(registerFor)) {
      return getIt.registerSingleton<T>(
        instance,
        instanceName: instanceName,
        signalsReady: signalsReady,
        dispose: dispose,
      );
    }
    return instance;
  }

  /// Registers an asynchronous singleton dependency of type [T].
  Future<void> singletonAsync<T extends Object>(
    FactoryFuncAsync<T> factoryFunc, {
    String? instanceName,
    Iterable<Type>? dependsOn,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
    Set<String>? registerFor,
  }) async {
    if (_canRegister(registerFor)) {
      getIt.registerSingletonAsync<T>(
        factoryFunc,
        instanceName: instanceName,
        dependsOn: dependsOn,
        signalsReady: signalsReady,
        dispose: dispose,
      );
    }
  }

  /// Registers a micro-package module or sub-module.
  FutureOr<void> initMicroPackage(MicroPackageModule module) {
    return module.init(this);
  }
}
