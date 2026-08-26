import 'package:codegen_example/cqrs_init.dart';
import 'package:codegen_example/features/billing/billing.dart';
import 'package:codegen_example/features/billing/gateway/gateway.dart';
import 'package:codegen_example/features/invoice/invoice.dart';
import 'package:codegen_example/features/orders/orders.dart';
import 'package:cqrs/cqrs.dart';

void main() async {
  final orderRepository = OrderRepository();
  final invoiceRepository = InvoiceRepository();
  final dispatcher = CqrsDispatcher();

  final invoiceHandler = InvoiceNotificationHandler();
  final analyticsHandler = OrderAnalyticsHandler();
  final auditLogHandler = InvoiceAuditLogHandler();
  final billingNotificationHandler = BillingNotificationHandler();

  // Wire all micro-packages (orders, invoice, billing, gateway) via AppCqrsModule.
  dispatcher.registry.registerModule(
    AppCqrsModule(
      billingCqrsModule: BillingCqrsModule(
        chargeBillingCommandHandler: () =>
            ChargeBillingCommandHandler(publisher: dispatcher),
        billingNotificationHandler: () => billingNotificationHandler,
      ),
      gatewayCqrsModule: const GatewayCqrsModule(),
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

  print('\n--- Charging Billing (Hybrid Feature) ---');
  final chargeId = await dispatcher.command(
    ChargeBillingCommand(customerId: 'CUST-007', amount: 2499.00),
  );
  print('Charge ID: $chargeId');

  print('\n--- Authorizing Payment Gateway (Nested Sub-Module) ---');
  final authCode = await dispatcher.command(
    AuthorizePaymentCommand(transactionId: chargeId, amount: 2499.00),
  );
  print('Authorization code: $authCode');

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
