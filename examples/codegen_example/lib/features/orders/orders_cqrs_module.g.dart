// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_cqrs_module.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

/// Generated registration helper for discovered CQRS handlers (AutoRegisterOrdersCqrs).
extension AutoRegisterOrdersCqrs on HandlerRegistry {
  void registerOrdersHandlers({
    required PlaceOrderCommandHandler Function() placeOrderCommandHandler,
    required GetOrderQueryHandler Function() getOrderQueryHandler,
    InvoiceNotificationHandler Function() invoiceNotificationHandler =
        InvoiceNotificationHandler.new,
    OrderAnalyticsHandler Function() orderAnalyticsHandler =
        OrderAnalyticsHandler.new,
  }) {
    registerCommand<PlaceOrderCommand, String>(placeOrderCommandHandler);
    registerQuery<GetOrderQuery, Order?>(getOrderQueryHandler);
    registerEvent<OrderPlacedEvent>(invoiceNotificationHandler);
    registerEvent<OrderPlacedEvent>(orderAnalyticsHandler);
  }
}
// ignore_for_file: prefer_initializing_formals

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers.
///
/// Usage:
/// ```dart
/// registry.registerModule(OrdersCqrsModule(
///   placeOrderCommandHandler: PlaceOrderCommandHandler.new,
///   getOrderQueryHandler: GetOrderQueryHandler.new,
/// ));
/// ```
class OrdersCqrsModule extends CqrsPackageModule {
  const OrdersCqrsModule({
    required PlaceOrderCommandHandler Function() placeOrderCommandHandler,
    required GetOrderQueryHandler Function() getOrderQueryHandler,
    InvoiceNotificationHandler Function() invoiceNotificationHandler =
        InvoiceNotificationHandler.new,
    OrderAnalyticsHandler Function() orderAnalyticsHandler =
        OrderAnalyticsHandler.new,
  }) : _placeOrderCommandHandler = placeOrderCommandHandler,
       _getOrderQueryHandler = getOrderQueryHandler,
       _invoiceNotificationHandler = invoiceNotificationHandler,
       _orderAnalyticsHandler = orderAnalyticsHandler,
       super();

  final PlaceOrderCommandHandler Function() _placeOrderCommandHandler;
  final GetOrderQueryHandler Function() _getOrderQueryHandler;
  final InvoiceNotificationHandler Function() _invoiceNotificationHandler;
  final OrderAnalyticsHandler Function() _orderAnalyticsHandler;

  @override
  void register(HandlerRegistry registry) {
    registry.registerOrdersHandlers(
      placeOrderCommandHandler: _placeOrderCommandHandler,
      getOrderQueryHandler: _getOrderQueryHandler,
      invoiceNotificationHandler: _invoiceNotificationHandler,
      orderAnalyticsHandler: _orderAnalyticsHandler,
    );
  }
}
