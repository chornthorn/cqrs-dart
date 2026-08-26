import 'package:codegen_example/cqrs_init.dart';
import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('Codegen Example CQRS Flow', () {
    late OrderRepository repository;
    late CqrsDispatcher dispatcher;
    late InvoiceNotificationHandler invoiceHandler;
    late OrderAnalyticsHandler analyticsHandler;

    setUp(() {
      repository = OrderRepository();
      dispatcher = CqrsDispatcher();
      invoiceHandler = InvoiceNotificationHandler();
      analyticsHandler = OrderAnalyticsHandler();

      dispatcher.registry.registerGeneratedHandlers(
        placeOrderCommandHandler: () => PlaceOrderCommandHandler(
          repository: repository,
          publisher: dispatcher,
        ),
        getOrderQueryHandler: () => GetOrderQueryHandler(
          repository: repository,
        ),
        invoiceNotificationHandler: () => invoiceHandler,
        orderAnalyticsHandler: () => analyticsHandler,
      );
    });

    test('dispatches PlaceOrderCommand, persists order, and notifies event listeners', () async {
      final orderId = await dispatcher.command(
        PlaceOrderCommand(item: 'iPhone 16 Pro', amount: 1199.00),
      );

      expect(orderId, startsWith('ORD-'));

      final order = await dispatcher.query(GetOrderQuery(orderId));
      expect(order, isNotNull);
      expect(order!.item, 'iPhone 16 Pro');
      expect(order.amount, 1199.00);

      expect(invoiceHandler.sentInvoices.length, 1);
      expect(
        invoiceHandler.sentInvoices.first,
        contains('Invoice sent for order $orderId (\$1199.0)'),
      );

      expect(analyticsHandler.recordedEvents.length, 1);
      expect(
        analyticsHandler.recordedEvents.first,
        contains('Analytics logged for order $orderId'),
      );
    });

    test('returns null when querying non-existent order', () async {
      final order = await dispatcher.query(GetOrderQuery('non-existent'));
      expect(order, isNull);
    });
  });
}
