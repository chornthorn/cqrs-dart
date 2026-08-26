/// Annotation to mark an initialization point for CQRS handler code generation.
///
/// Example:
/// ```dart
/// @CqrsInit()
/// void configureHandlers(HandlerRegistry registry) => registry.registerGeneratedHandlers();
/// ```
class CqrsInit {
  /// Creates a [CqrsInit] annotation.
  const CqrsInit({
    this.moduleName,
    this.methodName,
    this.extensionName,
    this.moduleClassName,
    this.modules = const [],
    this.useMicroPackage = false,
    this.includeDefaultFactories = true,
  });

  /// Creates a [CqrsInit] configured specifically for a micro-package / sub-module.
  ///
  /// When [moduleName] is set (e.g. `'Orders'`), the generated extension defaults to:
  /// - `extensionName`: `'AutoRegisterOrdersCqrs'`
  /// - `methodName`: `'registerOrdersHandlers'`
  /// - `moduleClassName`: `'OrdersCqrsModule'`
  const CqrsInit.microPackage({
    this.moduleName,
    this.methodName,
    this.extensionName,
    this.moduleClassName,
    this.modules = const [],
    this.useMicroPackage = true,
    this.includeDefaultFactories = true,
  });

  /// Optional module/micro-package name (e.g. 'Auth', 'Orders', 'Billing').
  ///
  /// When provided, defaults to:
  /// - `extensionName`: `AutoRegister${moduleName}Cqrs`
  /// - `methodName`: `register${moduleName}Handlers`
  /// - `moduleClassName`: `${moduleName}CqrsModule`
  final String? moduleName;

  /// Custom method name for the generated registration method.
  /// Defaults to `registerGeneratedHandlers` (or `register${moduleName}Handlers` if [moduleName] is set).
  final String? methodName;

  /// Custom extension name for the generated extension.
  /// Defaults to `AutoRegisterCqrs` (or `AutoRegister${moduleName}Cqrs` if [moduleName] is set).
  final String? extensionName;

  /// Custom class name for the generated [CqrsPackageModule] subclass.
  ///
  /// Only used when [useMicroPackage] is true.
  /// Defaults to `${moduleName}CqrsModule` (e.g. `AppCqrsModule`).
  final String? moduleClassName;

  /// List of [CqrsPackageModule] subclass types to compose in a root module.
  ///
  /// When [useMicroPackage] is `true` and this list is non-empty, the generator
  /// disables handler scanning and produces a **compositor** [CqrsPackageModule]
  /// subclass that accepts instances of each listed module and delegates
  /// `register()` to [HandlerRegistry.registerModules].
  ///
  /// Example:
  /// ```dart
  /// @CqrsInit(
  ///   moduleName: 'App',
  ///   useMicroPackage: true,
  ///   modules: [OrdersCqrsModule, InvoiceCqrsModule],
  /// )
  /// void configureCqrs() {}
  /// ```
  ///
  /// Generates:
  /// ```dart
  /// class AppCqrsModule extends CqrsPackageModule {
  ///   const AppCqrsModule({
  ///     required OrdersCqrsModule ordersCqrsModule,
  ///     required InvoiceCqrsModule invoiceCqrsModule,
  ///   });
  ///   @override
  ///   void register(HandlerRegistry registry) =>
  ///       registry.registerModules([ordersCqrsModule, invoiceCqrsModule]);
  /// }
  /// ```
  final List<Type> modules;

  /// Whether to enable micro-package code generation.
  ///
  /// When `true`:
  /// - If [modules] is non-empty, handler scanning is disabled and a compositor
  ///   [CqrsPackageModule] class is emitted.
  /// - If [modules] is empty, a feature [CqrsPackageModule] class is emitted
  ///   in addition to the registry extension.
  ///
  /// Defaults to `false` for [CqrsInit] and `true` for [CqrsMicroPackage].
  final bool useMicroPackage;

  /// Whether handlers with 0-argument constructors should have default factory values.
  final bool includeDefaultFactories;
}

/// Constant instance for `@cqrsInit` annotation.
const cqrsInit = CqrsInit();

/// Alias for [CqrsInit.microPackage] to mark a micro-package / sub-module.
///
/// Example:
/// ```dart
/// @CqrsMicroPackage(moduleName: 'Orders')
/// void configureOrders() {}
/// ```
class CqrsMicroPackage extends CqrsInit {
  /// Creates a [CqrsMicroPackage] annotation.
  const CqrsMicroPackage({
    super.moduleName,
    super.methodName,
    super.extensionName,
    super.moduleClassName,
    super.modules,
    super.useMicroPackage = true,
    super.includeDefaultFactories,
  }) : super.microPackage();
}

/// Constant instance for `@cqrsMicroPackage` annotation.
const cqrsMicroPackage = CqrsMicroPackage();

/// Optional annotation to explicitly mark a class as a CQRS handler.
class CqrsHandler {
  /// Creates a [CqrsHandler] annotation.
  const CqrsHandler();
}

/// Constant instance for `@cqrsHandler` annotation.
const cqrsHandler = CqrsHandler();
