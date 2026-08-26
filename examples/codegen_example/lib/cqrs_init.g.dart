// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cqrs_init.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

/// Generated registration helper for discovered CQRS handlers.
extension AutoRegisterCqrs on HandlerRegistry {
  void registerGeneratedHandlers({
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
