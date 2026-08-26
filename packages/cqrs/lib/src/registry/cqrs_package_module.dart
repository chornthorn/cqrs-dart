import 'handler_registry.dart';

/// Contract for a micro-package module containing CQRS handler registrations.
///
/// Micro-packages generated with `@CqrsMicroPackage` or `@CqrsInit.microPackage`
/// implement this interface so they can be registered individually or aggregated
/// in root application registries.
abstract class CqrsPackageModule {
  /// Const constructor for micro-package modules.
  const CqrsPackageModule();

  /// Registers all handlers from this module into the provided [registry].
  void register(HandlerRegistry registry);
}

/// Extension methods on [HandlerRegistry] for registering [CqrsPackageModule]s.
extension CqrsModuleRegistryExtension on HandlerRegistry {
  /// Registers a single [CqrsPackageModule] into this registry.
  void registerModule(CqrsPackageModule module) {
    module.register(this);
  }

  /// Registers multiple [CqrsPackageModule]s into this registry.
  void registerModules(Iterable<CqrsPackageModule> modules) {
    for (final module in modules) {
      module.register(this);
    }
  }
}
