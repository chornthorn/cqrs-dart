import 'package:codegen_example/features/billing/billing_cqrs_module.dart';
import 'package:codegen_example/features/billing/gateway/gateway_cqrs_module.dart';
import 'package:codegen_example/features/invoice/invoice_cqrs_module.dart';
import 'package:codegen_example/features/orders/orders_cqrs_module.dart';
import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('Multi-module CQRS Flow (Orders + Invoice micro-packages)', () {
    late OrderRepository orderRepository;
    late InvoiceRepository invoiceRepository;
    late CqrsDispatcher dispatcher;
    late InvoiceAuditLogHandler auditLogHandler;

    setUp(() {
      orderRepository = OrderRepository();
      invoiceRepository = InvoiceRepository();
      dispatcher = CqrsDispatcher();
      auditLogHandler = InvoiceAuditLogHandler();

      // Register both micro-package modules in one call.
      // Each module is completely independent — its own commands, queries,
      // events — but they share the same dispatcher/registry.
      dispatcher.registry.registerModules([
        OrdersCqrsModule(
          placeOrderCommandHandler: () => PlaceOrderCommandHandler(
            repository: orderRepository,
            publisher: dispatcher,
          ),
          getOrderQueryHandler: () => GetOrderQueryHandler(
            repository: orderRepository,
          ),
          // InvoiceNotificationHandler & OrderAnalyticsHandler are optional
          // (they have default constructors). Omitting them here to show the
          // minimal wiring needed for the invoice demo.
          invoiceNotificationHandler: () => InvoiceNotificationHandler(),
          orderAnalyticsHandler: () => OrderAnalyticsHandler(),
        ),
        InvoiceCqrsModule(
          generateInvoiceCommandHandler: () => GenerateInvoiceCommandHandler(
            repository: invoiceRepository,
            publisher: dispatcher,
          ),
          getInvoiceQueryHandler: () => GetInvoiceQueryHandler(
            repository: invoiceRepository,
          ),
          // InvoiceAuditLogHandler has a default constructor, so it's optional.
          // Override here to capture audit entries in the test.
          invoiceAuditLogHandler: () => auditLogHandler,
        ),
      ]);
    });

    test('places an order then generates and retrieves an invoice', () async {
      // Step 1: place an order via the Orders micro-package
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'iPad Pro', amount: 899.00),
      );
      expect(orderId, startsWith('ORD-'));

      // Verify order was persisted
      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order, isNotNull);
      expect(order!.item, 'iPad Pro');
      expect(order.amount, 899.00);

      // Step 2: generate an invoice via the Invoice micro-package
      final invoice = await dispatcher.command(
        GenerateInvoiceCommand(orderId: orderId, amount: order.amount),
      );
      expect(invoice.id, startsWith('INV-'));
      expect(invoice.orderId, orderId);
      expect(invoice.amount, 899.00);

      // Step 3: retrieve the invoice by ID
      final fetched = await dispatcher.query(GetInvoiceQuery(invoice.id));
      expect(fetched, isNotNull);
      expect(fetched!.id, invoice.id);
      expect(fetched.orderId, orderId);

      // Step 4: verify the audit log event handler fired
      expect(auditLogHandler.auditLog.length, 1);
      expect(
        auditLogHandler.auditLog.first,
        allOf(
          contains('[AUDIT]'),
          contains(invoice.id),
          contains(orderId),
          contains('\$899.0'),
        ),
      );
    });

    test('returns null when querying a non-existent invoice', () async {
      final result = await dispatcher.query(GetInvoiceQuery('INV-GHOST'));
      expect(result, isNull);
    });

    test('invoice module is fully independent from orders module', () async {
      // Generate an invoice without placing an order first
      // (the invoice module has no dependency on the orders module)
      final invoice = await dispatcher.command(
        GenerateInvoiceCommand(orderId: 'ORD-MANUAL', amount: 49.99),
      );
      expect(invoice.id, startsWith('INV-'));
      expect(invoice.orderId, 'ORD-MANUAL');

      // Audit log should have captured the event
      expect(auditLogHandler.auditLog, hasLength(1));
    });
  });

  group('Independent Micro-packages with Nested Sub-packages (Billing + Gateway)', () {
    late CqrsDispatcher dispatcher;
    late BillingNotificationHandler billingNotificationHandler;

    setUp(() {
      dispatcher = CqrsDispatcher();
      billingNotificationHandler = BillingNotificationHandler();

      // Register BillingCqrsModule and GatewayCqrsModule as independent modules
      dispatcher.registry.registerModules([
        BillingCqrsModule(
          chargeBillingCommandHandler: () =>
              ChargeBillingCommandHandler(publisher: dispatcher),
          billingNotificationHandler: () => billingNotificationHandler,
        ),
        const GatewayCqrsModule(),
      ]);
    });

    test('executes direct billing command and publishes event', () async {
      final chargeId = await dispatcher.command(
        const ChargeBillingCommand(customerId: 'CUST-100', amount: 299.00),
      );

      expect(chargeId, 'CHG-CUST-100');
      expect(billingNotificationHandler.notifications, hasLength(1));
      expect(
        billingNotificationHandler.notifications.first,
        contains('CHG-CUST-100'),
      );
    });

    test('executes nested gateway module handlers', () async {
      final authCode = await dispatcher.command(
        const AuthorizePaymentCommand(transactionId: 'TX-999', amount: 299.00),
      );
      expect(authCode, 'AUTH-TX-999-299');

      final isGatewayOk = await dispatcher.query(
        const GetGatewayStatusQuery(gatewayId: 'STRIPE_PRIMARY'),
      );
      expect(isGatewayOk, isTrue);
    });
  });
}
