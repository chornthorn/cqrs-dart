import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'billing_handler.cqrs.dart';

/// Micro-package entry point for the Billing feature.
@CqrsMicroPackage(moduleName: 'Billing')
void configureBillingHandlers() {}
