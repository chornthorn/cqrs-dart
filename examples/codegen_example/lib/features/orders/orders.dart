import 'package:cqrs/cqrs.dart';

// Domain Entities
class Order {
  Order({
    required this.id,
    required this.item,
    required this.amount,
  });

  final String id;
  final String item;
  final double amount;
}

class OrderRepository {
  final Map<String, Order> _orders = {};

  void save(Order order) {
    _orders[order.id] = order;
  }

  Order? findById(String id) => _orders[id];
}

// Events
class OrderPlacedEvent extends DomainEvent {
  OrderPlacedEvent(this.orderId, this.amount);
  final String orderId;
  final double amount;
}

// Command & Handler
class PlaceOrderCommand extends Command<String> {
  PlaceOrderCommand({required this.item, required this.amount});
  final String item;
  final double amount;
}

class PlaceOrderCommandHandler
    implements CommandHandler<PlaceOrderCommand, String> {
  PlaceOrderCommandHandler({
    required this._repository,
    required this._publisher,
  });

  final OrderRepository _repository;
  final EventPublisher _publisher;

  @override
  Future<String> execute(PlaceOrderCommand command) async {
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final order = Order(
      id: orderId,
      item: command.item,
      amount: command.amount,
    );
    _repository.save(order);
    await _publisher.publish(OrderPlacedEvent(orderId, command.amount));
    return orderId;
  }
}

// Query & Handler
class GetOrderQuery extends Query<Order?> {
  GetOrderQuery(this.orderId);
  final String orderId;
}

class GetOrderQueryHandler implements QueryHandler<GetOrderQuery, Order?> {
  GetOrderQueryHandler({required this._repository});

  final OrderRepository _repository;

  @override
  Future<Order?> execute(GetOrderQuery query) async {
    return _repository.findById(query.orderId);
  }
}

// Event Handlers (0-argument constructors)
class InvoiceNotificationHandler implements EventHandler<OrderPlacedEvent> {
  final List<String> sentInvoices = [];

  @override
  Future<void> handle(OrderPlacedEvent event) async {
    sentInvoices.add('Invoice sent for order ${event.orderId} (\$${event.amount})');
  }
}

class OrderAnalyticsHandler implements EventHandler<OrderPlacedEvent> {
  final List<String> recordedEvents = [];

  @override
  Future<void> handle(OrderPlacedEvent event) async {
    recordedEvents.add('Analytics logged for order ${event.orderId}');
  }
}
