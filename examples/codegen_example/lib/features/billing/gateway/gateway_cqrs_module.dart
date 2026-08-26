import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'gateway.dart';

export 'gateway.dart';

part 'gateway_cqrs_module.g.dart';

/// Micro-package entry point for the Gateway feature (nested under Billing).
@CqrsMicroPackage(moduleName: 'Gateway')
void configureGatewayHandlers() {}
