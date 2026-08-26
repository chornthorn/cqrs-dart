// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cqrs_init.dart';

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: prefer_initializing_formals

/// Generated compositor [CqrsPackageModule] that aggregates sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(AppCqrsModule(
///   ordersCqrsModule: OrdersCqrsModule(...),
///   invoiceCqrsModule: InvoiceCqrsModule(...),
/// ));
/// ```
class AppCqrsModule extends CqrsPackageModule {
  const AppCqrsModule({
    required OrdersCqrsModule ordersCqrsModule,
    required InvoiceCqrsModule invoiceCqrsModule,
  }) : _ordersCqrsModule = ordersCqrsModule,
       _invoiceCqrsModule = invoiceCqrsModule,
       super();

  final OrdersCqrsModule _ordersCqrsModule;
  final InvoiceCqrsModule _invoiceCqrsModule;

  @override
  void register(HandlerRegistry registry) {
    registry.registerModules([_ordersCqrsModule, _invoiceCqrsModule]);
  }
}
