import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'features/notification/notification_handler.dart';
import 'features/user/user_handler.dart';

export 'cqrs_init.cqrs.dart';
export 'features/notification/notification_handler.dart';
export 'features/user/user_handler.dart';

/// Root CQRS Compositor for hello_world application.
@CqrsInit(
  moduleName: 'App',
  useMicroPackage: true,
  modules: [
    UserCqrsModule,
    NotificationCqrsModule,
  ],
)
void configureCqrs() {}
