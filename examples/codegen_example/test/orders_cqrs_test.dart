import 'package:codegen_example/cqrs_init.dart';
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
        PlaceOrderCommand(item: 'MacBook Pro', amount: 2499.00),
      );

      expect(orderId, startsWith('ORD-'));

      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order, isNotNull);
      expect(order!.item, 'MacBook Pro');
      expect(order.amount, 2499.00);

      expect(invoiceHandler.sentInvoices.length, 1);
      expect(
        invoiceHandler.sentInvoices.first,
        contains('Invoice sent for order $orderId (\$2499.0)'),
      );

      expect(analyticsHandler.recordedEvents.length, 1);
      expect(
        analyticsHandler.recordedEvents.first,
        contains('Analytics logged for order $orderId'),
      );
    });

    test('module pattern: returns null for non-existent order', () async {
      final order = await dispatcher.query(GetOrderQuery('not-found'));
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

      // One call wires BOTH micro-packages via the generated AppCqrsModule.
      // The compositor delegates to registerModules([OrdersCqrsModule, InvoiceCqrsModule]).
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
      // Place an order
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'AirPods Pro', amount: 249.00),
      );
      expect(orderId, startsWith('ORD-'));

      // Orders event handler fired
      expect(invoiceHandler.sentInvoices, hasLength(1));

      // Generate an invoice for that order
      final invoice = await dispatcher.command(
        GenerateInvoiceCommand(orderId: orderId, amount: 249.00),
      );
      expect(invoice.id, startsWith('INV-'));
      expect(invoice.orderId, orderId);

      // Retrieve the invoice
      final fetched = await dispatcher.query(GetInvoiceQuery(invoice.id));
      expect(fetched?.id, invoice.id);

      // Invoice audit log event handler fired
      expect(auditLogHandler.auditLog, hasLength(1));
      expect(auditLogHandler.auditLog.first, contains('[AUDIT]'));
    });

    test('compositor: returns null for unknown order', () async {
      final order = await dispatcher.query(GetOrderQuery('ghost'));
      expect(order, isNull);
    });

    test('compositor: returns null for unknown invoice', () async {
      final invoice = await dispatcher.query(GetInvoiceQuery('INV-GHOST'));
      expect(invoice, isNull);
    });
  });
}

