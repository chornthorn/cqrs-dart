import 'package:codegen_example/cqrs_init.dart';
import 'package:cqrs/cqrs.dart';

void main() async {
  final repository = OrderRepository();
  final registry = HandlerRegistry();
  final dispatcher = CqrsDispatcher(registry: registry);

  final invoiceHandler = InvoiceNotificationHandler();
  final analyticsHandler = OrderAnalyticsHandler();

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

  print('--- Placing Order ---');
  final orderId = await dispatcher.command(
    PlaceOrderCommand(item: 'MacBook Pro M3', amount: 1999.99),
  );
  print('Created Order ID: $orderId');

  print('\n--- Handled Events ---');
  for (final inv in invoiceHandler.sentInvoices) {
    print('Invoice: $inv');
  }
  for (final evt in analyticsHandler.recordedEvents) {
    print('Analytics: $evt');
  }

  print('\n--- Querying Order ---');
  final order = await dispatcher.query(GetOrderQuery(orderId));
  if (order != null) {
    print('Found order: ${order.item} for \$${order.amount}');
  }
}
