// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_cqrs_module.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

/// Generated registration helper for discovered CQRS handlers (AutoRegisterInvoiceCqrs).
extension AutoRegisterInvoiceCqrs on HandlerRegistry {
  void registerInvoiceHandlers({
    required GenerateInvoiceCommandHandler Function()
    generateInvoiceCommandHandler,
    required GetInvoiceQueryHandler Function() getInvoiceQueryHandler,
    InvoiceAuditLogHandler Function() invoiceAuditLogHandler =
        InvoiceAuditLogHandler.new,
  }) {
    registerCommand<GenerateInvoiceCommand, Invoice>(
      generateInvoiceCommandHandler,
    );
    registerQuery<GetInvoiceQuery, Invoice?>(getInvoiceQueryHandler);
    registerEvent<InvoiceGeneratedEvent>(invoiceAuditLogHandler);
  }
}
// ignore_for_file: prefer_initializing_formals

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(InvoiceCqrsModule(
///   generateInvoiceCommandHandler: GenerateInvoiceCommandHandler.new,
///   getInvoiceQueryHandler: GetInvoiceQueryHandler.new,
/// ));
/// ```
class InvoiceCqrsModule extends CqrsPackageModule {
  const InvoiceCqrsModule({
    required GenerateInvoiceCommandHandler Function()
    generateInvoiceCommandHandler,
    required GetInvoiceQueryHandler Function() getInvoiceQueryHandler,
    InvoiceAuditLogHandler Function() invoiceAuditLogHandler =
        InvoiceAuditLogHandler.new,
  }) : _generateInvoiceCommandHandler = generateInvoiceCommandHandler,
       _getInvoiceQueryHandler = getInvoiceQueryHandler,
       _invoiceAuditLogHandler = invoiceAuditLogHandler,
       super();

  final GenerateInvoiceCommandHandler Function() _generateInvoiceCommandHandler;
  final GetInvoiceQueryHandler Function() _getInvoiceQueryHandler;
  final InvoiceAuditLogHandler Function() _invoiceAuditLogHandler;

  @override
  void register(HandlerRegistry registry) {
    registry.registerInvoiceHandlers(
      generateInvoiceCommandHandler: _generateInvoiceCommandHandler,
      getInvoiceQueryHandler: _getInvoiceQueryHandler,
      invoiceAuditLogHandler: _invoiceAuditLogHandler,
    );
  }
}
