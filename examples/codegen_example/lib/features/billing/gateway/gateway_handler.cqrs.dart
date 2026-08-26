// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/billing/gateway/gateway.dart' as _i2;
import 'package:codegen_example/features/billing/gateway/thorn_demo.dart'
    as _i3;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterGatewayCqrs).
extension AutoRegisterGatewayCqrs on _i1.HandlerRegistry {
  void registerGatewayHandlers({
    _i2.AuthorizePaymentCommandHandler Function()
        authorizePaymentCommandHandler =
        _i2.AuthorizePaymentCommandHandler.new,
    _i2.GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        _i2.GetGatewayStatusQueryHandler.new,
    _i3.FooBarEventHandler Function() fooBarEventHandler =
        _i3.FooBarEventHandler.new,
  }) {
    registerCommand<_i2.AuthorizePaymentCommand, String>(
      authorizePaymentCommandHandler,
    );
    registerQuery<_i2.GetGatewayStatusQuery, bool>(
      getGatewayStatusQueryHandler,
    );
    registerEvent<_i3.FooBarEvent>(fooBarEventHandler);
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(GatewayCqrsModule(
///   authorizePaymentCommandHandler: AuthorizePaymentCommandHandler.new,
/// ));
/// ```
class GatewayCqrsModule extends _i1.CqrsPackageModule {
  const GatewayCqrsModule({
    _i2.AuthorizePaymentCommandHandler Function()
        authorizePaymentCommandHandler =
        _i2.AuthorizePaymentCommandHandler.new,
    _i2.GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        _i2.GetGatewayStatusQueryHandler.new,
    _i3.FooBarEventHandler Function() fooBarEventHandler =
        _i3.FooBarEventHandler.new,
  }) : _authorizePaymentCommandHandler = authorizePaymentCommandHandler,
       _getGatewayStatusQueryHandler = getGatewayStatusQueryHandler,
       _fooBarEventHandler = fooBarEventHandler,
       super();

  final _i2.AuthorizePaymentCommandHandler Function()
  _authorizePaymentCommandHandler;
  final _i2.GetGatewayStatusQueryHandler Function()
  _getGatewayStatusQueryHandler;
  final _i3.FooBarEventHandler Function() _fooBarEventHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerGatewayHandlers(
      authorizePaymentCommandHandler: _authorizePaymentCommandHandler,
      getGatewayStatusQueryHandler: _getGatewayStatusQueryHandler,
      fooBarEventHandler: _fooBarEventHandler,
    );
  }
}
