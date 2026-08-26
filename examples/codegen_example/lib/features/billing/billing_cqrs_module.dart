import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'billing.dart';
import 'thorn_demo.dart';

export 'billing.dart';
export 'thorn_demo.dart';

part 'billing_cqrs_module.g.dart';

/// Micro-package entry point for the Billing feature.
@CqrsMicroPackage(moduleName: 'Billing')
void configureBillingHandlers() {}
