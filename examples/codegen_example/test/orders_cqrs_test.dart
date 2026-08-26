import 'package:codegen_example/cqrs_init.dart';
import 'package:codegen_example/features/billing/billing.dart';
import 'package:codegen_example/features/invoice/invoice.dart';
import 'package:codegen_example/features/orders/orders.dart';
import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('Codegen Example CQRS Flow (CqrsPackageModule pattern)', () {
    late OrderRepository repository;
    late CqrsDispatcher dispatcher;
    late InvoiceNotificationHandler invoiceHandler;
    late OrderAnalyticsHandler analyticsHandler;

    setUp(() {
      repository = OrderRepository();
      dispatcher = CqrsDispatcher();
      invoiceHandler = InvoiceNotificationHandler();
      analyticsHandler = OrderAnalyticsHandler();

      // Uses the generated OrdersCqrsModule — the micro-package pattern.
      dispatcher.registry.registerModule(
        OrdersCqrsModule(
          placeOrderCommandHandler: () => PlaceOrderCommandHandler(
            repository: repository,
            publisher: dispatcher,
          ),
          getOrderQueryHandler: () => GetOrderQueryHandler(
            repository: repository,
          ),
          invoiceNotificationHandler: () => invoiceHandler,
          orderAnalyticsHandler: () => analyticsHandler,
        ),
      );
    });

    test('module pattern: dispatches command and publishes event', () async {
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'MacBook Pro M4', amount: 2499.00),
      );

      expect(orderId, startsWith('ORD-'));
      expect(repository.findById(orderId), isNotNull);

      // Verify the event was handled by both handlers
      expect(invoiceHandler.sentInvoices, hasLength(1));
      expect(invoiceHandler.sentInvoices.first, contains(orderId));

      expect(analyticsHandler.recordedEvents, hasLength(1));
      expect(analyticsHandler.recordedEvents.first, contains(orderId));

      // Query the order back
      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order, isNotNull);
      expect(order!.item, 'MacBook Pro M4');
      expect(order.amount, 2499.00);
    });

    test('module pattern: returns null for non-existent order', () async {
      final order = await dispatcher.query(GetOrderQuery('non-existent'));
      expect(order, isNull);
    });
  });

  group('Root AppCqrsModule compositor pattern', () {
    late OrderRepository orderRepository;
    late InvoiceRepository invoiceRepository;
    late CqrsDispatcher dispatcher;
    late InvoiceNotificationHandler invoiceHandler;
    late InvoiceAuditLogHandler auditLogHandler;

    setUp(() {
      orderRepository = OrderRepository();
      invoiceRepository = InvoiceRepository();
      dispatcher = CqrsDispatcher();
      invoiceHandler = InvoiceNotificationHandler();
      auditLogHandler = InvoiceAuditLogHandler();

      // Registers ALL micro-packages in one call via generated AppCqrsModule.
      dispatcher.registry.registerModule(
        AppCqrsModule(
          billingCqrsModule: BillingCqrsModule(
            chargeBillingCommandHandler: () =>
                ChargeBillingCommandHandler(publisher: dispatcher),
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
    });

    test('compositor: places order then generates invoice end-to-end', () async {
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'iPhone 16 Pro', amount: 1199.00),
      );
      expect(orderId, startsWith('ORD-'));

      final invoice = await dispatcher.command(
        GenerateInvoiceCommand(orderId: orderId, amount: 1199.00),
      );
      expect(invoice.id, startsWith('INV-'));
      expect(invoice.amount, 1199.00);

      // Verify cross-module handlers ran
      expect(invoiceHandler.sentInvoices, hasLength(1));
      expect(auditLogHandler.auditLog, hasLength(1));

      // Query both modules
      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order?.item, 'iPhone 16 Pro');

      final fetchedInvoice = await dispatcher.query(GetInvoiceQuery(invoice.id));
      expect(fetchedInvoice?.amount, 1199.00);
    });

    test('compositor: returns null for unknown order', () async {
      final order = await dispatcher.query(GetOrderQuery('ORD-404'));
      expect(order, isNull);
    });

    test('compositor: returns null for unknown invoice', () async {
      final invoice = await dispatcher.query(GetInvoiceQuery('INV-404'));
      expect(invoice, isNull);
    });
  });
}
