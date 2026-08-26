import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_world/cqrs_init.dart';
import 'package:hello_world/features/notification/notification.dart';
import 'package:hello_world/features/user/user.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@module
abstract class CqrsModule {
  @singleton
  CqrsDispatcher get cqrsDispatcher {
    final dispatcher = CqrsDispatcher();

    dispatcher.registry.registerModule(
      AppCqrsModule(
        userCqrsModule: UserCqrsModule(
          createUserHandler: () => getIt<CreateUserHandler>(),
          getUserHandler: () => getIt<GetUserHandler>(),
          analyticsHandler: () => getIt<AnalyticsHandler>(),
          welcomeEmailHandler: () => getIt<WelcomeEmailHandler>(),
        ),
        notificationCqrsModule: NotificationCqrsModule(
          sendNotificationHandler: () => getIt<SendNotificationHandler>(),
          markNotificationAsReadHandler: () =>
              getIt<MarkNotificationAsReadHandler>(),
          getNotificationsHandler: () => getIt<GetNotificationsHandler>(),
          getUnreadNotificationCountHandler: () =>
              getIt<GetUnreadNotificationCountHandler>(),
          pushNotificationDeliveryHandler: () =>
              getIt<PushNotificationDeliveryHandler>(),
          notificationReadAnalyticsHandler: () =>
              getIt<NotificationReadAnalyticsHandler>(),
        ),
      ),
    );

    return dispatcher;
  }
}

@InjectableInit(
  initializerName: 'bootstrap',
  allowMultipleRegistrations: true,
)
Future<void> configureDependencies() async => getIt.bootstrap();
