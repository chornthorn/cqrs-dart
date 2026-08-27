import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  useMicroPackage: true,
)
Future<void> configureDependencies() async => getIt.init();
