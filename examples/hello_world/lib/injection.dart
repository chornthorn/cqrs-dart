import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'bootstrap',
  allowMultipleRegistrations: true,
  externalPackageModulesBefore: [ExternalModule(DartCqrsPackageModule)],
)
Future<void> configureDependencies() => getIt.bootstrap();
