/// Annotation to mark the root initialization point for dependency injection code generation.
class InjectableInit {
  /// The name of the generated initialization method/extension.
  final String initializerName;

  /// Whether to prefer relative imports over package imports in generated code.
  final bool preferRelativeImports;

  /// Whether to generate the initialization function as an extension on [GetIt].
  final bool asExtension;

  /// The directories to scan for injectable classes.
  final List<String> generateForDir;

  /// Whether to enable micro-package support.
  final bool useMicroPackage;

  /// Sub-modules / micro-package modules to compose in this root module.
  final List<Type> modules;

  /// Optional module/micro-package name (e.g. 'App', 'Auth', 'Orders').
  final String? moduleName;

  /// Custom class name for the generated module class (e.g. 'AppInjectableModule').
  final String? moduleClassName;

  /// Whether to allow registering multiple instances/dependencies without throw.
  final bool? allowMultipleRegistrations;

  /// Creates an [InjectableInit] annotation.
  const InjectableInit({
    this.initializerName = 'init',
    this.preferRelativeImports = true,
    this.asExtension = true,
    this.generateForDir = const ['lib'],
    this.useMicroPackage = false,
    this.modules = const [],
    this.moduleName,
    this.moduleClassName,
    this.allowMultipleRegistrations,
  });

  /// Creates an [InjectableInit] configured specifically for a micro-package / sub-module.
  const InjectableInit.microPackage({
    this.initializerName = 'init',
    this.preferRelativeImports = true,
    this.asExtension = true,
    this.generateForDir = const ['lib'],
    this.useMicroPackage = true,
    this.modules = const [],
    this.moduleName,
    this.moduleClassName,
    this.allowMultipleRegistrations,
  });
}

/// Constant instance for [@injectableInit] annotation.
const injectableInit = InjectableInit();

/// Annotation to mark a feature directory or sub-module as an isolated micro-package.
///
/// Example:
/// ```dart
/// @InjectableMicroPackage(moduleName: 'Auth')
/// void configureAuthModule() {}
/// ```
class InjectableMicroPackage extends InjectableInit {
  /// Creates an [InjectableMicroPackage] annotation.
  const InjectableMicroPackage({
    super.initializerName = 'init',
    super.preferRelativeImports = true,
    super.asExtension = true,
    super.generateForDir = const ['lib'],
    super.useMicroPackage = true,
    super.modules = const [],
    super.moduleName,
    super.moduleClassName,
    super.allowMultipleRegistrations,
  }) : super.microPackage();
}

/// Constant instance for [@injectableMicroPackage] annotation.
const injectableMicroPackage = InjectableMicroPackage();
