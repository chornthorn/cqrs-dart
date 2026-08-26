import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'invoice.dart';
export 'invoice_cqrs_module.cqrs.dart';

/// Micro-package entry point for the Invoice feature.
@CqrsMicroPackage(moduleName: 'Invoice')
void configureInvoiceHandlers() {}
