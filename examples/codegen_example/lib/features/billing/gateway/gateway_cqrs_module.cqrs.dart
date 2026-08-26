// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

import 'package:cqrs/cqrs.dart';
import 'gateway.dart';

/// Generated registration helper for discovered CQRS handlers (AutoRegisterGatewayCqrs).
extension AutoRegisterGatewayCqrs on HandlerRegistry {
  void registerGatewayHandlers({
    AuthorizePaymentCommandHandler Function() authorizePaymentCommandHandler =
        AuthorizePaymentCommandHandler.new,
    GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        GetGatewayStatusQueryHandler.new,
  }) {
    registerCommand<AuthorizePaymentCommand, String>(
      authorizePaymentCommandHandler,
    );
    registerQuery<GetGatewayStatusQuery, bool>(getGatewayStatusQueryHandler);
  }
}
// ignore_for_file: prefer_initializing_formals

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(GatewayCqrsModule(
/// ));
/// ```
class GatewayCqrsModule extends CqrsPackageModule {
  const GatewayCqrsModule({
    AuthorizePaymentCommandHandler Function() authorizePaymentCommandHandler =
        AuthorizePaymentCommandHandler.new,
    GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        GetGatewayStatusQueryHandler.new,
  }) : _authorizePaymentCommandHandler = authorizePaymentCommandHandler,
       _getGatewayStatusQueryHandler = getGatewayStatusQueryHandler,
       super();

  final AuthorizePaymentCommandHandler Function()
  _authorizePaymentCommandHandler;
  final GetGatewayStatusQueryHandler Function() _getGatewayStatusQueryHandler;

  @override
  void register(HandlerRegistry registry) {
    registry.registerGatewayHandlers(
      authorizePaymentCommandHandler: _authorizePaymentCommandHandler,
      getGatewayStatusQueryHandler: _getGatewayStatusQueryHandler,
    );
  }
}
