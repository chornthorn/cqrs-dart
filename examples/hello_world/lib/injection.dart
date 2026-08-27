import 'package:cqrs/cqrs.dart';
import 'package:hello_world/cqrs_init.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@externalModule
abstract class CqrsModule {
  @Injectable(scope: Scope.singleton)
  CqrsDispatcher get cqrsDispatcher => CqrsDispatcher()
    ..registry.registerModule(AppCqrsModule.fromLocator(getIt.get));
}

@InjectableInit(
  initializerName: 'bootstrap',
  allowMultipleRegistrations: true,
)
Future<void> configureDependencies() async => getIt.bootstrap();
