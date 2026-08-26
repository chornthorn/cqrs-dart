import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'gateway_handler.cqrs.dart';

/// Micro-package entry point for the Gateway feature (nested under Billing).
@CqrsMicroPackage(moduleName: 'Gateway')
void configureGatewayHandlers() {}
