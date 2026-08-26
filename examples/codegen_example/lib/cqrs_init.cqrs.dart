// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/billing/billing_handler.dart' as _i2;
import 'package:codegen_example/features/billing/gateway/gateway_handler.dart'
    as _i3;
import 'package:codegen_example/features/invoice/invoice_handler.dart' as _i4;
import 'package:codegen_example/features/orders/orders_handler.dart' as _i5;

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(AppCqrsModule(
///   billingCqrsModule: BillingCqrsModule(...),
///   gatewayCqrsModule: GatewayCqrsModule(...),
///   invoiceCqrsModule: InvoiceCqrsModule(...),
///   ordersCqrsModule: OrdersCqrsModule(...),
/// ));
/// ```
class AppCqrsModule extends _i1.CqrsPackageModule {
  const AppCqrsModule({
    required _i2.BillingCqrsModule billingCqrsModule,
    required _i3.GatewayCqrsModule gatewayCqrsModule,
    required _i4.InvoiceCqrsModule invoiceCqrsModule,
    required _i5.OrdersCqrsModule ordersCqrsModule,
  }) : _billingCqrsModule = billingCqrsModule,
       _gatewayCqrsModule = gatewayCqrsModule,
       _invoiceCqrsModule = invoiceCqrsModule,
       _ordersCqrsModule = ordersCqrsModule,
       super();

  final _i2.BillingCqrsModule _billingCqrsModule;
  final _i3.GatewayCqrsModule _gatewayCqrsModule;
  final _i4.InvoiceCqrsModule _invoiceCqrsModule;
  final _i5.OrdersCqrsModule _ordersCqrsModule;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerModules([
      _billingCqrsModule,
      _gatewayCqrsModule,
      _invoiceCqrsModule,
      _ordersCqrsModule,
    ]);
  }
}
