// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cqrs_init.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: prefer_initializing_formals

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(AppCqrsModule(
///   ordersCqrsModule: OrdersCqrsModule(...),
///   invoiceCqrsModule: InvoiceCqrsModule(...),
///   billingCqrsModule: BillingCqrsModule(...),
///   gatewayCqrsModule: GatewayCqrsModule(...),
/// ));
/// ```
class AppCqrsModule extends CqrsPackageModule {
  const AppCqrsModule({
    required OrdersCqrsModule ordersCqrsModule,
    required InvoiceCqrsModule invoiceCqrsModule,
    required BillingCqrsModule billingCqrsModule,
    required GatewayCqrsModule gatewayCqrsModule,
  }) : _ordersCqrsModule = ordersCqrsModule,
       _invoiceCqrsModule = invoiceCqrsModule,
       _billingCqrsModule = billingCqrsModule,
       _gatewayCqrsModule = gatewayCqrsModule,
       super();

  final OrdersCqrsModule _ordersCqrsModule;
  final InvoiceCqrsModule _invoiceCqrsModule;
  final BillingCqrsModule _billingCqrsModule;
  final GatewayCqrsModule _gatewayCqrsModule;

  @override
  void register(HandlerRegistry registry) {
    registry.registerModules([
      _ordersCqrsModule,
      _invoiceCqrsModule,
      _billingCqrsModule,
      _gatewayCqrsModule,
    ]);
  }
}
