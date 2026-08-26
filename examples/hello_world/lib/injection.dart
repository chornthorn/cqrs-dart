import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@module
abstract class CqrsModule {
  @singleton
  CqrsDispatcher get cqrsDispatcher => DefaultCqrsDispatcher(
        registry: ResolverHandlerRegistry(
          resolver: (type) =>
              getIt.isRegistered(type: type) ? getIt.get(type: type) : null,
          eventResolver: <E extends DomainEvent>() =>
              getIt.isRegistered<EventHandler<E>>()
                  ? getIt.getAll<EventHandler<E>>().toList()
                  : const [],
        ),
      );
}

@InjectableInit(
  initializerName: 'bootstrap',
  allowMultipleRegistrations: true,
)
Future<void> configureDependencies() async => getIt.bootstrap();
