import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'invoice.dart';

export 'invoice.dart';

part 'invoice_cqrs_module.g.dart';

/// Micro-package entry point for the Invoice feature.
///
/// Running `build_runner` against this file will generate:
/// - `AutoRegisterInvoiceCqrs` extension on [HandlerRegistry]
/// - `InvoiceCqrsModule` class implementing [CqrsPackageModule]
///
/// Usage with the module pattern:
/// ```dart
/// registry.registerModules([
///   OrdersCqrsModule(...),
///   InvoiceCqrsModule(
///     generateInvoiceCommandHandler: () => GenerateInvoiceCommandHandler(
///       repository: invoiceRepository,
///       publisher: publisher,
///     ),
///     getInvoiceQueryHandler: () => GetInvoiceQueryHandler(
///       repository: invoiceRepository,
///     ),
///   ),
/// ]);
/// ```
@CqrsMicroPackage(moduleName: 'Invoice')
void configureInvoiceHandlers() {}
