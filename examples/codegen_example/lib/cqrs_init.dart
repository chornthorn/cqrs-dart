import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'features/billing/billing_handler.dart';
import 'features/billing/gateway/demo/thorn_demo_handler.dart';
import 'features/billing/gateway/gateway_handler.dart';
import 'features/invoice/invoice_handler.dart';
import 'features/orders/orders_handler.dart';

export 'cqrs_init.cqrs.dart';
export 'features/billing/billing_handler.dart';
export 'features/billing/gateway/demo/thorn_demo_handler.dart';
export 'features/billing/gateway/gateway_handler.dart';
export 'features/invoice/invoice_handler.dart';
export 'features/orders/orders_handler.dart';

/// Root application CQRS entry point.
@CqrsInit(
  moduleName: 'App',
  useMicroPackage: true,
  generateInjectable: false,
  modules: [
    OrdersCqrsModule,
    InvoiceCqrsModule,
    BillingCqrsModule,
    GatewayCqrsModule,
    ThornDemoCqrsModule,
  ],
)
void configureCqrs() {}
