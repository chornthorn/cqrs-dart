import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'gateway_cqrs_module.cqrs.dart';

/// Micro-package entry point for the Gateway feature (nested under Billing).
@CqrsMicroPackage(moduleName: 'Gateway')
void configureGatewayHandlers() {}
