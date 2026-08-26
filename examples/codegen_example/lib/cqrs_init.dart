import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'features/billing/billing_cqrs_module.dart';
import 'features/billing/gateway/gateway_cqrs_module.dart';
import 'features/invoice/invoice_cqrs_module.dart';
import 'features/orders/orders_cqrs_module.dart';

export 'cqrs_init.cqrs.dart';
export 'features/billing/billing_cqrs_module.dart';
export 'features/billing/gateway/gateway_cqrs_module.dart';
export 'features/invoice/invoice_cqrs_module.dart';
export 'features/orders/orders_cqrs_module.dart';

/// Root application CQRS entry point.
@CqrsInit(
  moduleName: 'App',
  useMicroPackage: true,
  modules: [
    OrdersCqrsModule,
    InvoiceCqrsModule,
    BillingCqrsModule,
    GatewayCqrsModule,
  ],
)
void configureCqrs() {}
