// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/invoice/invoice.dart' as _i2;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterInvoiceCqrs).
extension AutoRegisterInvoiceCqrs on _i1.HandlerRegistry {
  void registerInvoiceHandlers({
    required _i2.GenerateInvoiceCommandHandler Function()
    generateInvoiceCommandHandler,
    required _i2.GetInvoiceQueryHandler Function() getInvoiceQueryHandler,
    _i2.InvoiceAuditLogHandler Function() invoiceAuditLogHandler =
        _i2.InvoiceAuditLogHandler.new,
  }) {
    registerCommand<_i2.GenerateInvoiceCommand, _i2.Invoice>(
      generateInvoiceCommandHandler,
    );
    registerQuery<_i2.GetInvoiceQuery, _i2.Invoice?>(getInvoiceQueryHandler);
    registerEvent<_i2.InvoiceGeneratedEvent>(invoiceAuditLogHandler);
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(InvoiceCqrsModule(
///   generateInvoiceCommandHandler: GenerateInvoiceCommandHandler.new,
/// ));
/// ```
class InvoiceCqrsModule extends _i1.CqrsPackageModule {
  const InvoiceCqrsModule({
    required _i2.GenerateInvoiceCommandHandler Function()
    generateInvoiceCommandHandler,
    required _i2.GetInvoiceQueryHandler Function() getInvoiceQueryHandler,
    _i2.InvoiceAuditLogHandler Function() invoiceAuditLogHandler =
        _i2.InvoiceAuditLogHandler.new,
  }) : _generateInvoiceCommandHandler = generateInvoiceCommandHandler,
       _getInvoiceQueryHandler = getInvoiceQueryHandler,
       _invoiceAuditLogHandler = invoiceAuditLogHandler,
       super();

  final _i2.GenerateInvoiceCommandHandler Function()
  _generateInvoiceCommandHandler;
  final _i2.GetInvoiceQueryHandler Function() _getInvoiceQueryHandler;
  final _i2.InvoiceAuditLogHandler Function() _invoiceAuditLogHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerInvoiceHandlers(
      generateInvoiceCommandHandler: _generateInvoiceCommandHandler,
      getInvoiceQueryHandler: _getInvoiceQueryHandler,
      invoiceAuditLogHandler: _invoiceAuditLogHandler,
    );
  }
}
