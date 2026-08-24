// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dart_cqrs/dart_cqrs.dart' as _i609;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hello_world/features/notification/application/commands/mark_notification_as_read_command.dart'
    as _i176;
import 'package:hello_world/features/notification/application/commands/send_notification_command.dart'
    as _i50;
import 'package:hello_world/features/notification/application/event_handlers/notification_read_analytics_handler.dart'
    as _i51;
import 'package:hello_world/features/notification/application/event_handlers/push_notification_delivery_handler.dart'
    as _i762;
import 'package:hello_world/features/notification/application/queries/get_notifications_query.dart'
    as _i883;
import 'package:hello_world/features/notification/application/queries/get_unread_notification_count_query.dart'
    as _i455;
import 'package:hello_world/features/notification/domain/entities/app_notification.dart'
    as _i820;
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart'
    as _i299;
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart'
    as _i473;
import 'package:hello_world/features/notification/infrastructure/notification_log.dart'
    as _i382;
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart'
    as _i357;
import 'package:hello_world/features/user/application/commands/create_user_command.dart'
    as _i365;
import 'package:hello_world/features/user/application/event_handlers/analytics_handler.dart'
    as _i833;
import 'package:hello_world/features/user/application/event_handlers/welcome_email_handler.dart'
    as _i951;
import 'package:hello_world/features/user/application/queries/get_user_query.dart'
    as _i148;
import 'package:hello_world/features/user/domain/entities/user.dart' as _i768;
import 'package:hello_world/features/user/domain/events/user_created_event.dart'
    as _i220;
import 'package:hello_world/features/user/infrastructure/side_effect_log.dart'
    as _i1055;
import 'package:hello_world/features/user/infrastructure/user_repository.dart'
    as _i1067;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> bootstrap({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    this.enableRegisteringMultipleInstancesOfOneType();
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    await _i609.DartCqrsPackageModule().init(gh);
    gh.lazySingleton<_i382.NotificationLog>(() => _i382.NotificationLog());
    gh.lazySingleton<_i357.NotificationRepository>(
      () => _i357.NotificationRepository(),
    );
    gh.lazySingleton<_i1055.SideEffectLog>(() => _i1055.SideEffectLog());
    gh.lazySingleton<_i1067.UserRepository>(() => _i1067.UserRepository());
    gh.factory<_i609.QueryHandler<_i148.GetUserQuery, _i768.User?>>(
      () => _i148.GetUserHandler(gh<_i1067.UserRepository>()),
    );
    gh.factory<_i609.EventHandler<_i220.UserCreatedEvent>>(
      () => _i833.AnalyticsHandler(gh<_i1055.SideEffectLog>()),
    );
    gh.factory<_i609.CommandHandler<_i365.CreateUserCommand, bool>>(
      () => _i365.CreateUserHandler(
        gh<_i609.CqrsDispatcher>(),
        gh<_i1067.UserRepository>(),
      ),
    );
    gh.factory<_i609.QueryHandler<_i455.GetUnreadNotificationCountQuery, int>>(
      () => _i455.GetUnreadNotificationCountHandler(
        gh<_i357.NotificationRepository>(),
      ),
    );
    gh.factory<_i609.EventHandler<_i299.NotificationReadEvent>>(
      () => _i51.NotificationReadAnalyticsHandler(gh<_i382.NotificationLog>()),
    );
    gh.factory<_i609.EventHandler<_i473.NotificationSentEvent>>(
      () => _i762.PushNotificationDeliveryHandler(gh<_i382.NotificationLog>()),
    );
    gh.factory<
      _i609.QueryHandler<
        _i883.GetNotificationsQuery,
        List<_i820.AppNotification>
      >
    >(() => _i883.GetNotificationsHandler(gh<_i357.NotificationRepository>()));
    gh.factory<_i609.EventHandler<_i220.UserCreatedEvent>>(
      () => _i951.WelcomeEmailHandler(gh<_i1055.SideEffectLog>()),
    );
    gh.factory<_i609.CommandHandler<_i176.MarkNotificationAsReadCommand, bool>>(
      () => _i176.MarkNotificationAsReadHandler(
        gh<_i609.CqrsDispatcher>(),
        gh<_i357.NotificationRepository>(),
      ),
    );
    gh.factory<_i609.CommandHandler<_i50.SendNotificationCommand, String>>(
      () => _i50.SendNotificationHandler(
        gh<_i609.CqrsDispatcher>(),
        gh<_i357.NotificationRepository>(),
      ),
    );
    return this;
  }
}
