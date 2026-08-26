// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/orders/orders.dart' as _i2;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterOrdersCqrs).
extension AutoRegisterOrdersCqrs on _i1.HandlerRegistry {
  void registerOrdersHandlers({
    required _i2.PlaceOrderCommandHandler Function() placeOrderCommandHandler,
    required _i2.GetOrderQueryHandler Function() getOrderQueryHandler,
    _i2.InvoiceNotificationHandler Function() invoiceNotificationHandler =
        _i2.InvoiceNotificationHandler.new,
    _i2.OrderAnalyticsHandler Function() orderAnalyticsHandler =
        _i2.OrderAnalyticsHandler.new,
  }) {
    registerCommand<_i2.PlaceOrderCommand, String>(placeOrderCommandHandler);
    registerQuery<_i2.GetOrderQuery, _i2.Order?>(getOrderQueryHandler);
    registerEvent<_i2.OrderPlacedEvent>(invoiceNotificationHandler);
    registerEvent<_i2.OrderPlacedEvent>(orderAnalyticsHandler);
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(OrdersCqrsModule(
///   placeOrderCommandHandler: PlaceOrderCommandHandler.new,
///   getOrderQueryHandler: GetOrderQueryHandler.new,
/// ));
/// ```
class OrdersCqrsModule extends _i1.CqrsPackageModule {
  const OrdersCqrsModule({
    required _i2.PlaceOrderCommandHandler Function() placeOrderCommandHandler,
    required _i2.GetOrderQueryHandler Function() getOrderQueryHandler,
    _i2.InvoiceNotificationHandler Function() invoiceNotificationHandler =
        _i2.InvoiceNotificationHandler.new,
    _i2.OrderAnalyticsHandler Function() orderAnalyticsHandler =
        _i2.OrderAnalyticsHandler.new,
  }) : _placeOrderCommandHandler = placeOrderCommandHandler,
       _getOrderQueryHandler = getOrderQueryHandler,
       _invoiceNotificationHandler = invoiceNotificationHandler,
       _orderAnalyticsHandler = orderAnalyticsHandler,
       super();

  final _i2.PlaceOrderCommandHandler Function() _placeOrderCommandHandler;
  final _i2.GetOrderQueryHandler Function() _getOrderQueryHandler;
  final _i2.InvoiceNotificationHandler Function() _invoiceNotificationHandler;
  final _i2.OrderAnalyticsHandler Function() _orderAnalyticsHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerOrdersHandlers(
      placeOrderCommandHandler: _placeOrderCommandHandler,
      getOrderQueryHandler: _getOrderQueryHandler,
      invoiceNotificationHandler: _invoiceNotificationHandler,
      orderAnalyticsHandler: _orderAnalyticsHandler,
    );
  }
}
