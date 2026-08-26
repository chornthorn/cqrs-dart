import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'orders.dart';

/// Micro-package entry point for the Orders feature.
@CqrsMicroPackage(moduleName: 'Orders')
void configureOrdersHandlers() {}
