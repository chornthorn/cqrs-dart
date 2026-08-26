// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/billing/gateway/demo/thorn_demo.dart'
    as _i2;
import 'package:codegen_example/features/billing/gateway/gateway.dart' as _i3;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterGatewayCqrs).
extension AutoRegisterGatewayCqrs on _i1.HandlerRegistry {
  void registerGatewayHandlers({
    _i2.FooBarEventHandler Function() fooBarEventHandler =
        _i2.FooBarEventHandler.new,
    _i3.AuthorizePaymentCommandHandler Function()
        authorizePaymentCommandHandler =
        _i3.AuthorizePaymentCommandHandler.new,
    _i3.GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        _i3.GetGatewayStatusQueryHandler.new,
  }) {
    registerEvent<_i2.FooBarEvent>(fooBarEventHandler);
    registerCommand<_i3.AuthorizePaymentCommand, String>(
      authorizePaymentCommandHandler,
    );
    registerQuery<_i3.GetGatewayStatusQuery, bool>(
      getGatewayStatusQueryHandler,
    );
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(GatewayCqrsModule(
///   fooBarEventHandler: FooBarEventHandler.new,
/// ));
/// ```
class GatewayCqrsModule extends _i1.CqrsPackageModule {
  const GatewayCqrsModule({
    _i2.FooBarEventHandler Function() fooBarEventHandler =
        _i2.FooBarEventHandler.new,
    _i3.AuthorizePaymentCommandHandler Function()
        authorizePaymentCommandHandler =
        _i3.AuthorizePaymentCommandHandler.new,
    _i3.GetGatewayStatusQueryHandler Function() getGatewayStatusQueryHandler =
        _i3.GetGatewayStatusQueryHandler.new,
  }) : _fooBarEventHandler = fooBarEventHandler,
       _authorizePaymentCommandHandler = authorizePaymentCommandHandler,
       _getGatewayStatusQueryHandler = getGatewayStatusQueryHandler,
       super();

  final _i2.FooBarEventHandler Function() _fooBarEventHandler;
  final _i3.AuthorizePaymentCommandHandler Function()
  _authorizePaymentCommandHandler;
  final _i3.GetGatewayStatusQueryHandler Function()
  _getGatewayStatusQueryHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerGatewayHandlers(
      fooBarEventHandler: _fooBarEventHandler,
      authorizePaymentCommandHandler: _authorizePaymentCommandHandler,
      getGatewayStatusQueryHandler: _getGatewayStatusQueryHandler,
    );
  }
}
