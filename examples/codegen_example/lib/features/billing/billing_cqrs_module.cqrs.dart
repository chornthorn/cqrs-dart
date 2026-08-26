// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/billing/billing.dart' as _i2;
import 'package:codegen_example/features/billing/thorn_demo.dart' as _i3;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterBillingCqrs).
extension AutoRegisterBillingCqrs on _i1.HandlerRegistry {
  void registerBillingHandlers({
    required _i2.ChargeBillingCommandHandler Function()
    chargeBillingCommandHandler,
    _i2.BillingNotificationHandler Function() billingNotificationHandler =
        _i2.BillingNotificationHandler.new,
    _i3.FooBarEventHandler Function() fooBarEventHandler =
        _i3.FooBarEventHandler.new,
  }) {
    registerCommand<_i2.ChargeBillingCommand, String>(
      chargeBillingCommandHandler,
    );
    registerEvent<_i2.BillingChargedEvent>(billingNotificationHandler);
    registerEvent<_i3.FooBarEvent>(fooBarEventHandler);
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(BillingCqrsModule(
///   chargeBillingCommandHandler: ChargeBillingCommandHandler.new,
/// ));
/// ```
class BillingCqrsModule extends _i1.CqrsPackageModule {
  const BillingCqrsModule({
    required _i2.ChargeBillingCommandHandler Function()
    chargeBillingCommandHandler,
    _i2.BillingNotificationHandler Function() billingNotificationHandler =
        _i2.BillingNotificationHandler.new,
    _i3.FooBarEventHandler Function() fooBarEventHandler =
        _i3.FooBarEventHandler.new,
  }) : _chargeBillingCommandHandler = chargeBillingCommandHandler,
       _billingNotificationHandler = billingNotificationHandler,
       _fooBarEventHandler = fooBarEventHandler,
       super();

  final _i2.ChargeBillingCommandHandler Function() _chargeBillingCommandHandler;
  final _i2.BillingNotificationHandler Function() _billingNotificationHandler;
  final _i3.FooBarEventHandler Function() _fooBarEventHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerBillingHandlers(
      chargeBillingCommandHandler: _chargeBillingCommandHandler,
      billingNotificationHandler: _billingNotificationHandler,
      fooBarEventHandler: _fooBarEventHandler,
    );
  }
}
