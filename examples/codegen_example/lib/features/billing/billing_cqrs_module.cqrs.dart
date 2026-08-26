// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

import 'package:cqrs/cqrs.dart';
import 'billing.dart';
import 'thorn_demo.dart';

/// Generated registration helper for discovered CQRS handlers (AutoRegisterBillingCqrs).
extension AutoRegisterBillingCqrs on HandlerRegistry {
  void registerBillingHandlers({
    required ChargeBillingCommandHandler Function() chargeBillingCommandHandler,
    BillingNotificationHandler Function() billingNotificationHandler =
        BillingNotificationHandler.new,
    FooBarEventHandler Function() fooBarEventHandler = FooBarEventHandler.new,
  }) {
    registerCommand<ChargeBillingCommand, String>(chargeBillingCommandHandler);
    registerEvent<BillingChargedEvent>(billingNotificationHandler);
    registerEvent<FooBarEvent>(fooBarEventHandler);
  }
}
// ignore_for_file: prefer_initializing_formals

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(BillingCqrsModule(
///   chargeBillingCommandHandler: ChargeBillingCommandHandler.new,
/// ));
/// ```
class BillingCqrsModule extends CqrsPackageModule {
  const BillingCqrsModule({
    required ChargeBillingCommandHandler Function() chargeBillingCommandHandler,
    BillingNotificationHandler Function() billingNotificationHandler =
        BillingNotificationHandler.new,
    FooBarEventHandler Function() fooBarEventHandler = FooBarEventHandler.new,
  }) : _chargeBillingCommandHandler = chargeBillingCommandHandler,
       _billingNotificationHandler = billingNotificationHandler,
       _fooBarEventHandler = fooBarEventHandler,
       super();

  final ChargeBillingCommandHandler Function() _chargeBillingCommandHandler;
  final BillingNotificationHandler Function() _billingNotificationHandler;
  final FooBarEventHandler Function() _fooBarEventHandler;

  @override
  void register(HandlerRegistry registry) {
    registry.registerBillingHandlers(
      chargeBillingCommandHandler: _chargeBillingCommandHandler,
      billingNotificationHandler: _billingNotificationHandler,
      fooBarEventHandler: _fooBarEventHandler,
    );
  }
}
