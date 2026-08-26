import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'billing.dart';
export 'billing_cqrs_module.cqrs.dart';

/// Micro-package entry point for the Billing feature.
@CqrsMicroPackage(moduleName: 'Billing')
void configureBillingHandlers() {}
