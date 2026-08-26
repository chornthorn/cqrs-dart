// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_cqrs_module.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

/// Generated registration helper for discovered CQRS handlers (AutoRegisterBillingCqrs).
extension AutoRegisterBillingCqrs on HandlerRegistry {
  void registerBillingHandlers({
    required ChargeBillingCommandHandler Function() chargeBillingCommandHandler,
    BillingNotificationHandler Function() billingNotificationHandler =
        BillingNotificationHandler.new,
  }) {
    registerCommand<ChargeBillingCommand, String>(chargeBillingCommandHandler);
    registerEvent<BillingChargedEvent>(billingNotificationHandler);
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
  }) : _chargeBillingCommandHandler = chargeBillingCommandHandler,
       _billingNotificationHandler = billingNotificationHandler,
       super();

  final ChargeBillingCommandHandler Function() _chargeBillingCommandHandler;
  final BillingNotificationHandler Function() _billingNotificationHandler;

  @override
  void register(HandlerRegistry registry) {
    registry.registerBillingHandlers(
      chargeBillingCommandHandler: _chargeBillingCommandHandler,
      billingNotificationHandler: _billingNotificationHandler,
    );
  }
}
