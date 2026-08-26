import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'orders_handler.cqrs.dart';

/// Micro-package entry point for the Orders feature.
@CqrsMicroPackage(moduleName: 'Orders')
void configureOrdersHandlers() {}
