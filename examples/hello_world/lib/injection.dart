import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'bootstrap',
  allowMultipleRegistrations: true,
  externalPackageModulesBefore: [ExternalModule(CqrsPackageModule)],
)
Future<void> configureDependencies() => getIt.bootstrap();
