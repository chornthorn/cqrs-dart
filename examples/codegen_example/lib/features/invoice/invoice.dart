import 'package:cqrs/cqrs.dart';

// ---------------------------------------------------------------------------
// Entity & Repository
// ---------------------------------------------------------------------------

/// Represents a generated invoice for an order.
class Invoice {
  Invoice({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.issuedAt,
  });

  final String id;
  final String orderId;
  final double amount;
  final DateTime issuedAt;

  @override
  String toString() =>
      'Invoice($id, order=$orderId, amount=\$$amount, issuedAt=$issuedAt)';
}

/// In-memory invoice store.
class InvoiceRepository {
  final Map<String, Invoice> _invoices = {};

  void save(Invoice invoice) => _invoices[invoice.id] = invoice;

  Invoice? findById(String id) => _invoices[id];

  List<Invoice> findByOrderId(String orderId) =>
      _invoices.values.where((i) => i.orderId == orderId).toList();
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

/// Fired when a new invoice has been generated.
class InvoiceGeneratedEvent extends Event {
  InvoiceGeneratedEvent({
    required this.invoiceId,
    required this.orderId,
    required this.amount,
  });

  final String invoiceId;
  final String orderId;
  final double amount;
}

// ---------------------------------------------------------------------------
// Command: GenerateInvoiceCommand → Invoice
// ---------------------------------------------------------------------------

/// Command that generates an invoice for a given order.
class GenerateInvoiceCommand extends Command<Invoice> {
  GenerateInvoiceCommand({required this.orderId, required this.amount});

  final String orderId;
  final double amount;
}

/// Handles [GenerateInvoiceCommand]: creates, persists, and publishes.
class GenerateInvoiceCommandHandler
    implements CommandHandler<GenerateInvoiceCommand, Invoice> {
  GenerateInvoiceCommandHandler({
    required this.repository,
    required this.publisher,
  });

  final InvoiceRepository repository;
  final EventPublisher publisher;

  @override
  Future<Invoice> execute(GenerateInvoiceCommand command) async {
    final invoice = Invoice(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      orderId: command.orderId,
      amount: command.amount,
      issuedAt: DateTime.now(),
    );
    repository.save(invoice);
    await publisher.publish(InvoiceGeneratedEvent(
      invoiceId: invoice.id,
      orderId: invoice.orderId,
      amount: invoice.amount,
    ));
    return invoice;
  }
}

// ---------------------------------------------------------------------------
// Query: GetInvoiceQuery → Invoice?
// ---------------------------------------------------------------------------

/// Query to retrieve an invoice by its ID.
class GetInvoiceQuery extends Query<Invoice?> {
  GetInvoiceQuery(this.invoiceId);

  final String invoiceId;
}

/// Handles [GetInvoiceQuery].
class GetInvoiceQueryHandler implements QueryHandler<GetInvoiceQuery, Invoice?> {
  GetInvoiceQueryHandler({required this.repository});

  final InvoiceRepository repository;

  @override
  Future<Invoice?> execute(GetInvoiceQuery query) async =>
      repository.findById(query.invoiceId);
}

// ---------------------------------------------------------------------------
// Event Handler: InvoiceAuditLogHandler (has default constructor → optional)
// ---------------------------------------------------------------------------

/// Keeps an in-memory audit log of all generated invoices.
/// Has a default constructor so it is **optional** in the generated module.
class InvoiceAuditLogHandler implements EventHandler<InvoiceGeneratedEvent> {
  final List<String> auditLog = [];

  @override
  Future<void> handle(InvoiceGeneratedEvent event) async {
    auditLog.add(
      '[AUDIT] Invoice ${event.invoiceId} generated for order '
      '${event.orderId} — \$${event.amount}',
    );
  }
}
