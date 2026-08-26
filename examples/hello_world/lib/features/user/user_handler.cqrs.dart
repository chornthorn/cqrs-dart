// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:hello_world/features/user/application/commands/create_user_command.dart'
    as _i2;
import 'package:hello_world/features/user/application/event_handlers/analytics_handler.dart'
    as _i3;
import 'package:hello_world/features/user/domain/events/user_created_event.dart'
    as _i4;
import 'package:hello_world/features/user/application/event_handlers/welcome_email_handler.dart'
    as _i5;
import 'package:hello_world/features/user/application/queries/get_user_query.dart'
    as _i6;
import 'package:hello_world/features/user/domain/entities/user.dart' as _i7;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterUserCqrs).
extension AutoRegisterUserCqrs on _i1.HandlerRegistry {
  void registerUserHandlers({
    required _i2.CreateUserHandler Function() createUserHandler,
    required _i3.AnalyticsHandler Function() analyticsHandler,
    required _i5.WelcomeEmailHandler Function() welcomeEmailHandler,
    required _i6.GetUserHandler Function() getUserHandler,
  }) {
    registerCommand<_i2.CreateUserCommand, bool>(createUserHandler);
    registerEvent<_i4.UserCreatedEvent>(analyticsHandler);
    registerEvent<_i4.UserCreatedEvent>(welcomeEmailHandler);
    registerQuery<_i6.GetUserQuery, _i7.User?>(getUserHandler);
  }

  /// Registers all handlers by resolving them from a service locator.
  void registerUserHandlersFromLocator(T Function<T extends Object>() locator) {
    registerUserHandlers(
      createUserHandler: () => locator<_i2.CreateUserHandler>(),
      analyticsHandler: () => locator<_i3.AnalyticsHandler>(),
      welcomeEmailHandler: () => locator<_i5.WelcomeEmailHandler>(),
      getUserHandler: () => locator<_i6.GetUserHandler>(),
    );
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(UserCqrsModule(
///   createUserHandler: CreateUserHandler.new,
///   analyticsHandler: AnalyticsHandler.new,
///   welcomeEmailHandler: WelcomeEmailHandler.new,
///   getUserHandler: GetUserHandler.new,
/// ));
/// ```
class UserCqrsModule extends _i1.CqrsPackageModule {
  const UserCqrsModule({
    required _i2.CreateUserHandler Function() createUserHandler,
    required _i3.AnalyticsHandler Function() analyticsHandler,
    required _i5.WelcomeEmailHandler Function() welcomeEmailHandler,
    required _i6.GetUserHandler Function() getUserHandler,
  }) : _createUserHandler = createUserHandler,
       _analyticsHandler = analyticsHandler,
       _welcomeEmailHandler = welcomeEmailHandler,
       _getUserHandler = getUserHandler,
       super();

  /// Factory constructor that resolves all handlers from a dependency locator (e.g. GetIt.instance.get).
  factory UserCqrsModule.fromLocator(T Function<T extends Object>() locator) {
    return UserCqrsModule(
      createUserHandler: () => locator<_i2.CreateUserHandler>(),
      analyticsHandler: () => locator<_i3.AnalyticsHandler>(),
      welcomeEmailHandler: () => locator<_i5.WelcomeEmailHandler>(),
      getUserHandler: () => locator<_i6.GetUserHandler>(),
    );
  }

  final _i2.CreateUserHandler Function() _createUserHandler;
  final _i3.AnalyticsHandler Function() _analyticsHandler;
  final _i5.WelcomeEmailHandler Function() _welcomeEmailHandler;
  final _i6.GetUserHandler Function() _getUserHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerUserHandlers(
      createUserHandler: _createUserHandler,
      analyticsHandler: _analyticsHandler,
      welcomeEmailHandler: _welcomeEmailHandler,
      getUserHandler: _getUserHandler,
    );
  }
}
