import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'orders.dart';

export 'orders.dart';

part 'orders_cqrs_module.g.dart';

/// Micro-package entry point for the Orders feature.
///
/// Running `build_runner` against this file will generate:
/// - `AutoRegisterOrdersCqrs` extension on [HandlerRegistry]
/// - `OrdersCqrsModule` class implementing [CqrsPackageModule]
///
/// Usage with the module pattern:
/// ```dart
/// final registry = HandlerRegistry();
/// registry.registerModule(OrdersCqrsModule(
///   placeOrderCommandHandler: () => PlaceOrderCommandHandler(
///     repository: repository,
///     publisher: publisher,
///   ),
///   getOrderQueryHandler: () => GetOrderQueryHandler(repository: repository),
/// ));
/// ```
@CqrsMicroPackage(moduleName: 'Orders')
void configureOrdersHandlers() {}
