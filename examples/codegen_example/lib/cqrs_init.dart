import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'features/invoice/invoice_cqrs_module.dart';
import 'features/orders/orders_cqrs_module.dart';

export 'features/invoice/invoice_cqrs_module.dart';
export 'features/orders/orders_cqrs_module.dart';

part 'cqrs_init.g.dart';

/// Root application CQRS entry point.
///
/// Declares which micro-package modules to compose.
/// Running `build_runner` generates an [AppCqrsModule] compositor class.
@CqrsInit(
  moduleName: 'App',
  useMicroPackage: true,
  modules: [OrdersCqrsModule, InvoiceCqrsModule],
)
void configureCqrs() {}
