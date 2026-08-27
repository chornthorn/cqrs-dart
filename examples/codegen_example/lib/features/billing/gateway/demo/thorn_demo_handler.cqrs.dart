// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// CqrsGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals

import 'package:cqrs/cqrs.dart' as _i1;
import 'package:codegen_example/features/billing/gateway/demo/thorn_demo.dart'
    as _i2;

/// Generated registration helper for discovered CQRS handlers (AutoRegisterThornDemoCqrs).
extension AutoRegisterThornDemoCqrs on _i1.HandlerRegistry {
  void registerThornDemoHandlers({
    _i2.FooBarEventHandler Function() fooBarEventHandler =
        _i2.FooBarEventHandler.new,
  }) {
    registerEvent<_i2.FooBarEvent>(fooBarEventHandler);
  }
}

/// Generated [CqrsPackageModule] for auto-discovered CQRS handlers and sub-modules.
///
/// Usage:
/// ```dart
/// registry.registerModule(ThornDemoCqrsModule(
///   fooBarEventHandler: FooBarEventHandler.new,
/// ));
/// ```
class ThornDemoCqrsModule extends _i1.CqrsPackageModule {
  const ThornDemoCqrsModule({
    _i2.FooBarEventHandler Function() fooBarEventHandler =
        _i2.FooBarEventHandler.new,
  }) : _fooBarEventHandler = fooBarEventHandler,
       super();

  final _i2.FooBarEventHandler Function() _fooBarEventHandler;

  @override
  void register(_i1.HandlerRegistry registry) {
    registry.registerThornDemoHandlers(fooBarEventHandler: _fooBarEventHandler);
  }
}
