import 'package:codegen_example/cqrs_init.dart';
import 'package:cqrs/cqrs.dart';

void main() async {
  final orderRepository = OrderRepository();
  final invoiceRepository = InvoiceRepository();
  final dispatcher = CqrsDispatcher();

  final invoiceHandler = InvoiceNotificationHandler();
  final analyticsHandler = OrderAnalyticsHandler();
  final auditLogHandler = InvoiceAuditLogHandler();

  // Wire both micro-packages via the generated AppCqrsModule compositor.
  dispatcher.registry.registerModule(
    AppCqrsModule(
      ordersCqrsModule: OrdersCqrsModule(
        placeOrderCommandHandler: () => PlaceOrderCommandHandler(
          repository: orderRepository,
          publisher: dispatcher,
        ),
        getOrderQueryHandler: () => GetOrderQueryHandler(
          repository: orderRepository,
        ),
        invoiceNotificationHandler: () => invoiceHandler,
        orderAnalyticsHandler: () => analyticsHandler,
      ),
      invoiceCqrsModule: InvoiceCqrsModule(
        generateInvoiceCommandHandler: () => GenerateInvoiceCommandHandler(
          repository: invoiceRepository,
          publisher: dispatcher,
        ),
        getInvoiceQueryHandler: () => GetInvoiceQueryHandler(
          repository: invoiceRepository,
        ),
        invoiceAuditLogHandler: () => auditLogHandler,
      ),
    ),
  );

  print('--- Placing Order ---');
  final orderId = await dispatcher.command(
    PlaceOrderCommand(item: 'MacBook Pro M4', amount: 2499.00),
  );
  print('Created Order ID: $orderId');

  print('\n--- Orders event handlers ---');
  for (final inv in invoiceHandler.sentInvoices) {
    print('  Invoice notification: $inv');
  }
  for (final evt in analyticsHandler.recordedEvents) {
    print('  Analytics: $evt');
  }

  print('\n--- Generating Invoice ---');
  final invoice = await dispatcher.command(
    GenerateInvoiceCommand(orderId: orderId, amount: 2499.00),
  );
  print('Invoice ID: ${invoice.id}');

  print('\n--- Invoice audit log ---');
  for (final entry in auditLogHandler.auditLog) {
    print('  $entry');
  }

  print('\n--- Querying Order ---');
  final order = await dispatcher.query(GetOrderQuery(orderId));
  if (order != null) {
    print('Found order: ${order.item} for \$${order.amount}');
  }

  print('\n--- Querying Invoice ---');
  final fetched = await dispatcher.query(GetInvoiceQuery(invoice.id));
  if (fetched != null) {
    print('Found invoice: ${fetched.id} for \$${fetched.amount}');
  }
}
