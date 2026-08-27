// dart format width=80

// **************************************************************************
// InjectableGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:injectable/injectable.dart' as _i1;
import 'package:get_it/get_it.dart' as _i2;
import 'package:hello_world/features/notification/application/commands/mark_notification_as_read_command.dart'
    as _i3;
import 'package:cqrs/src/dispatcher/cqrs_dispatcher.dart' as _i4;
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart'
    as _i5;
import 'package:hello_world/features/notification/application/commands/send_notification_command.dart'
    as _i6;
import 'package:hello_world/features/notification/application/event_handlers/notification_read_analytics_handler.dart'
    as _i7;
import 'package:hello_world/features/notification/infrastructure/notification_log.dart'
    as _i8;
import 'package:hello_world/features/notification/application/event_handlers/push_notification_delivery_handler.dart'
    as _i9;
import 'package:hello_world/features/notification/application/queries/get_notifications_query.dart'
    as _i10;
import 'package:hello_world/features/notification/application/queries/get_unread_notification_count_query.dart'
    as _i11;
import 'package:hello_world/features/user/application/commands/create_user_command.dart'
    as _i12;
import 'package:hello_world/features/user/infrastructure/user_repository.dart'
    as _i13;
import 'package:hello_world/features/user/application/event_handlers/analytics_handler.dart'
    as _i14;
import 'package:hello_world/features/user/infrastructure/side_effect_log.dart'
    as _i15;
import 'package:hello_world/features/user/application/event_handlers/welcome_email_handler.dart'
    as _i16;
import 'package:hello_world/features/user/application/queries/get_user_query.dart'
    as _i17;
import 'package:hello_world/injection.dart' as _i18;

extension GetItInjectableX on _i2.GetIt {
  _i2.GetIt bootstrap({
    String? environment,
    _i1.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i1.GetItHelper(
      this,
      environment: environment,
      environmentFilter: environmentFilter,
    );
    final cqrsModule = _$CqrsModule();
    gh.factory<_i3.MarkNotificationAsReadHandler>(
      () => _i3.MarkNotificationAsReadHandler(
        gh<_i4.CqrsDispatcher>(),
        gh<_i5.NotificationRepository>(),
      ),
    );
    gh.factory<_i6.SendNotificationHandler>(
      () => _i6.SendNotificationHandler(
        gh<_i4.CqrsDispatcher>(),
        gh<_i5.NotificationRepository>(),
      ),
    );
    gh.factory<_i7.NotificationReadAnalyticsHandler>(
      () => _i7.NotificationReadAnalyticsHandler(gh<_i8.NotificationLog>()),
    );
    gh.factory<_i9.PushNotificationDeliveryHandler>(
      () => _i9.PushNotificationDeliveryHandler(gh<_i8.NotificationLog>()),
    );
    gh.factory<_i10.GetNotificationsHandler>(
      () => _i10.GetNotificationsHandler(gh<_i5.NotificationRepository>()),
    );
    gh.factory<_i11.GetUnreadNotificationCountHandler>(
      () => _i11.GetUnreadNotificationCountHandler(
        gh<_i5.NotificationRepository>(),
      ),
    );
    gh.lazySingleton<_i8.NotificationLog>(() => _i8.NotificationLog());
    gh.lazySingleton<_i5.NotificationRepository>(
      () => _i5.NotificationRepository(),
    );
    gh.factory<_i12.CreateUserHandler>(
      () => _i12.CreateUserHandler(
        gh<_i4.CqrsDispatcher>(),
        gh<_i13.UserRepository>(),
      ),
    );
    gh.factory<_i14.AnalyticsHandler>(
      () => _i14.AnalyticsHandler(gh<_i15.SideEffectLog>()),
    );
    gh.factory<_i16.WelcomeEmailHandler>(
      () => _i16.WelcomeEmailHandler(gh<_i15.SideEffectLog>()),
    );
    gh.factory<_i17.GetUserHandler>(
      () => _i17.GetUserHandler(gh<_i13.UserRepository>()),
    );
    gh.lazySingleton<_i15.SideEffectLog>(() => _i15.SideEffectLog());
    gh.lazySingleton<_i13.UserRepository>(() => _i13.UserRepository());
    gh.singleton<_i4.CqrsDispatcher>(cqrsModule.cqrsDispatcher);
    return this;
  }
}

class _$CqrsModule extends _i18.CqrsModule {}
