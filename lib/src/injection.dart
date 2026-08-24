import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'core/dispatcher.dart';

/// Generates [DartCqrsPackageModule] so host apps can register this package
/// with injectable's [ExternalModule].
@InjectableInit.microPackage()
void initMicroPackage() {}

/// Registers [CqrsDispatcher] and allows multiple handlers per event type.
///
/// Host apps that use injectable should prefer [ExternalModule] instead.
void registerCqrs([GetIt? instance]) {
  final getIt = instance ?? GetIt.instance;
  getIt.enableRegisteringMultipleInstancesOfOneType();
  if (!getIt.isRegistered<CqrsDispatcher>()) {
    getIt.registerSingleton<CqrsDispatcher>(CqrsDispatcher());
  }
}
