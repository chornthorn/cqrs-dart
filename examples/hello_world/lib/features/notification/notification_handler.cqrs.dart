// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:hello_world/features/notification/application/commands/mark_notification_as_read_command.dart'
    as _i2;
import 'package:hello_world/features/notification/application/commands/send_notification_command.dart'
    as _i3;
import 'package:hello_world/features/notification/application/event_handlers/notification_read_analytics_handler.dart'
    as _i4;
import 'package:hello_world/features/notification/domain/events/notification_read_event.dart'
    as _i5;
import 'package:hello_world/features/notification/application/event_handlers/push_notification_delivery_handler.dart'
    as _i6;
import 'package:hello_world/features/notification/domain/events/notification_sent_event.dart'
    as _i7;
import 'package:hello_world/features/notification/application/queries/get_notifications_query.dart'
    as _i8;
import 'package:hello_world/features/notification/domain/entities/app_notification.dart'
    as _i9;
import 'package:hello_world/features/notification/application/queries/get_unread_notification_count_query.dart'
    as _i10;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterNotificationCqrs).
extension AutoRegisterNotificationCqrs on _i1.HandlerRegistry {
  void registerNotificationHandlers({
    required _i2.MarkNotificationAsReadHandler Function()
    markNotificationAsReadHandler,
    required _i3.SendNotificationHandler Function() sendNotificationHandler,
    required _i4.NotificationReadAnalyticsHandler Function()
    notificationReadAnalyticsHandler,
    required _i6.PushNotificationDeliveryHandler Function()
    pushNotificationDeliveryHandler,
    required _i8.GetNotificationsHandler Function() getNotificationsHandler,
    required _i10.GetUnreadNotificationCountHandler Function()
    getUnreadNotificationCountHandler,
  }) {
    registerCommand<_i2.MarkNotificationAsReadCommand, bool>(
      markNotificationAsReadHandler,
    );
    registerCommand<_i3.SendNotificationCommand, String>(
      sendNotificationHandler,
    );
    registerEvent<_i5.NotificationReadEvent>(notificationReadAnalyticsHandler);
    registerEvent<_i7.NotificationSentEvent>(pushNotificationDeliveryHandler);
    registerQuery<_i8.GetNotificationsQuery, List<_i9.AppNotification>>(
      getNotificationsHandler,
    );
    registerQuery<_i10.GetUnreadNotificationCountQuery, int>(
      getUnreadNotificationCountHandler,
    );
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(NotificationCqrsModule(
///   markNotificationAsReadHandler: MarkNotificationAsReadHandler.new,
///   sendNotificationHandler: SendNotificationHandler.new,
///   notificationReadAnalyticsHandler: NotificationReadAnalyticsHandler.new,
///   pushNotificationDeliveryHandler: PushNotificationDeliveryHandler.new,
///   getNotificationsHandler: GetNotificationsHandler.new,
///   getUnreadNotificationCountHandler: GetUnreadNotificationCountHandler.new,
/// ));
/// ```
class NotificationCqrsModule extends _i1.CqrsPackageModule {
  const NotificationCqrsModule({
    required _i2.MarkNotificationAsReadHandler Function()
    markNotificationAsReadHandler,
    required _i3.SendNotificationHandler Function() sendNotificationHandler,
    required _i4.NotificationReadAnalyticsHandler Function()
    notificationReadAnalyticsHandler,
    required _i6.PushNotificationDeliveryHandler Function()
    pushNotificationDeliveryHandler,
    required _i8.GetNotificationsHandler Function() getNotificationsHandler,
    required _i10.GetUnreadNotificationCountHandler Function()
    getUnreadNotificationCountHandler,
  }) : _markNotificationAsReadHandler = markNotificationAsReadHandler,
       _sendNotificationHandler = sendNotificationHandler,
       _notificationReadAnalyticsHandler = notificationReadAnalyticsHandler,
       _pushNotificationDeliveryHandler = pushNotificationDeliveryHandler,
       _getNotificationsHandler = getNotificationsHandler,
       _getUnreadNotificationCountHandler = getUnreadNotificationCountHandler,
       super();

  final _i2.MarkNotificationAsReadHandler Function()
  _markNotificationAsReadHandler;
  final _i3.SendNotificationHandler Function() _sendNotificationHandler;
  final _i4.NotificationReadAnalyticsHandler Function()
  _notificationReadAnalyticsHandler;
  final _i6.PushNotificationDeliveryHandler Function()
  _pushNotificationDeliveryHandler;
  final _i8.GetNotificationsHandler Function() _getNotificationsHandler;
  final _i10.GetUnreadNotificationCountHandler Function()
  _getUnreadNotificationCountHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerNotificationHandlers(
      markNotificationAsReadHandler: _markNotificationAsReadHandler,
      sendNotificationHandler: _sendNotificationHandler,
      notificationReadAnalyticsHandler: _notificationReadAnalyticsHandler,
      pushNotificationDeliveryHandler: _pushNotificationDeliveryHandler,
      getNotificationsHandler: _getNotificationsHandler,
      getUnreadNotificationCountHandler: _getUnreadNotificationCountHandler,
    );
  }
}
