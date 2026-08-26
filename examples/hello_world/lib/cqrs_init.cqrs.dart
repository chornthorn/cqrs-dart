// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:hello_world/features/notification/notification_handler.dart'
    as _i2;
import 'package:hello_world/features/user/user_handler.dart' as _i3;

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(AppCqrsModule(
///   notificationCqrsModule: NotificationCqrsModule(...),
///   userCqrsModule: UserCqrsModule(...),
/// ));
/// ```
class AppCqrsModule extends _i1.CqrsPackageModule {
  const AppCqrsModule({
    required _i2.NotificationCqrsModule notificationCqrsModule,
    required _i3.UserCqrsModule userCqrsModule,
  }) : _notificationCqrsModule = notificationCqrsModule,
       _userCqrsModule = userCqrsModule,
       super();

  final _i2.NotificationCqrsModule _notificationCqrsModule;
  final _i3.UserCqrsModule _userCqrsModule;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerModules([_notificationCqrsModule, _userCqrsModule]);
  }
}
