import 'package:codegen_example/cqrs_init.dart';
import 'package:codegen_example/features/billing/billing.dart';
import 'package:codegen_example/features/billing/gateway/gateway.dart';
import 'package:codegen_example/features/invoice/invoice.dart';
import 'package:codegen_example/features/orders/orders.dart';
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
        ),
        InvoiceCqrsModule(
          generateInvoiceCommandHandler: () => GenerateInvoiceCommandHandler(
            repository: invoiceRepository,
            publisher: dispatcher,
          ),
          getInvoiceQueryHandler: () => GetInvoiceQueryHandler(
            repository: invoiceRepository,
          ),
          invoiceAuditLogHandler: () => auditLogHandler,
        ),
      ]);
    });

    test('places an order then generates and retrieves an invoice', () async {
      // 1. Dispatch Order command
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'Pixel 9 Pro', amount: 999.00),
      );
      expect(orderId, startsWith('ORD-'));

      // 2. Dispatch Invoice command
      final invoice = await dispatcher.command(
        GenerateInvoiceCommand(orderId: orderId, amount: 999.00),
      );
      expect(invoice.id, startsWith('INV-'));
      expect(invoice.orderId, orderId);
      expect(invoice.amount, 999.00);

      // 3. Query Order
      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order, isNotNull);
      expect(order!.item, 'Pixel 9 Pro');

      // 4. Query Invoice
      final fetchedInvoice = await dispatcher.query(GetInvoiceQuery(invoice.id));
      expect(fetchedInvoice, isNotNull);
      expect(fetchedInvoice!.id, invoice.id);
      expect(fetchedInvoice.amount, 999.00);

      // 5. Verify audit log was recorded
      expect(auditLogHandler.auditLog, hasLength(1));
      expect(auditLogHandler.auditLog.first, contains(invoice.id));
    });

    test('returns null when querying a non-existent invoice', () async {
      final invoice = await dispatcher.query(GetInvoiceQuery('INV-DOES-NOT-EXIST'));
      expect(invoice, isNull);
    });

    test('invoice module is fully independent from orders module', () async {
      // Create a dispatcher with ONLY the invoice module
      final invoiceOnlyDispatcher = CqrsDispatcher();
      invoiceOnlyDispatcher.registry.registerModule(
        InvoiceCqrsModule(
          generateInvoiceCommandHandler: () => GenerateInvoiceCommandHandler(
            repository: invoiceRepository,
            publisher: invoiceOnlyDispatcher,
          ),
          getInvoiceQueryHandler: () => GetInvoiceQueryHandler(
            repository: invoiceRepository,
          ),
        ),
      );

      // Invoice commands work
      final invoice = await invoiceOnlyDispatcher.command(
        GenerateInvoiceCommand(orderId: 'EXTERNAL-123', amount: 50.00),
      );
      expect(invoice.id, startsWith('INV-'));

      // Order commands fail because Orders module is NOT registered
      expect(
        () => invoiceOnlyDispatcher.command(
          PlaceOrderCommand(item: 'Keyboard', amount: 100.00),
        ),
        throwsA(isA<HandlerNotFoundException>()),
      );
    });
  });

  group('Independent Micro-packages with Nested Sub-packages (Billing + Gateway)', () {
    late CqrsDispatcher dispatcher;
    late BillingNotificationHandler billingNotificationHandler;

    setUp(() {
      dispatcher = CqrsDispatcher();
      billingNotificationHandler = BillingNotificationHandler();

      // Register both independent modules
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
        ChargeBillingCommand(customerId: 'CUST-007', amount: 500.00),
      );

      expect(chargeId, 'CHG-CUST-007');
      expect(billingNotificationHandler.notifications, hasLength(1));
      expect(billingNotificationHandler.notifications.first, contains('CUST-007'));
    });

    test('executes nested gateway module handlers', () async {
      final authCode = await dispatcher.command(
        AuthorizePaymentCommand(transactionId: 'TXN-999', amount: 750.00),
      );
      expect(authCode, 'AUTH-TXN-999-750');

      final status = await dispatcher.query(
        GetGatewayStatusQuery(gatewayId: 'GW-STRIPE'),
      );
      expect(status, isTrue);
    });
  });
}
