import 'package:codegen_example/cqrs_init.dart';
import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('Codegen Example CQRS Flow', () {
    late InMemoryHandlerRegistry registry;
    late DefaultCqrsDispatcher dispatcher;
    late OrderRepository repository;
    late InvoiceNotificationHandler invoiceHandler;
    late OrderAnalyticsHandler analyticsHandler;

    setUp(() {
      repository = OrderRepository();
      registry = InMemoryHandlerRegistry();
      dispatcher = DefaultCqrsDispatcher(registry: registry);

      invoiceHandler = InvoiceNotificationHandler();
      analyticsHandler = OrderAnalyticsHandler();

      // Use the generated extension method
      registry.registerGeneratedHandlers(
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

    test('dispatches PlaceOrderCommand, persists order, and notifies event listeners',
        () async {
      final orderId = await dispatcher.dispatchCommand(
        PlaceOrderCommand(item: 'MacBook Pro', amount: 2499.0),
      );

      expect(orderId, startsWith('ORD-'));

      // Check event handlers were notified
      expect(invoiceHandler.sentInvoices.length, 1);
      expect(
        invoiceHandler.sentInvoices.first,
        contains('Invoice sent for order $orderId (\$2499.0)'),
      );

      expect(analyticsHandler.recordedEvents.length, 1);
      expect(
        analyticsHandler.recordedEvents.first,
        'Analytics logged for order $orderId',
      );

      // Query the order
      final fetched = await dispatcher.dispatchQuery(GetOrderQuery(orderId));
      expect(fetched, isNotNull);
      expect(fetched!.id, orderId);
      expect(fetched.item, 'MacBook Pro');
      expect(fetched.amount, 2499.0);
    });

    test('returns null when querying non-existent order', () async {
      final order = await dispatcher.dispatchQuery(GetOrderQuery('invalid-id'));
      expect(order, isNull);
    });
  });
}
