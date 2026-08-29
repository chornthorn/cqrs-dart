/// Lifetime scope for injectable dependencies.
enum Scope {
  /// A new instance is created on every lookup.
  factory,

  /// A single shared instance created eagerly at initialization.
  singleton,

  /// A single shared instance created lazily upon first lookup.
  lazySingleton,
}

/// Marks a class or factory method as a dependency eligible for injection.
///
/// Example:
/// ```dart
/// @Injectable()
/// class AuthService {}
/// ```
class Injectable {
  /// The lifecycle scope (factory, singleton, lazySingleton).
  final Scope scope;

  /// The type to bind this dependency to in the service locator.
  final Type? as;

  /// The environments in which this dependency is active.
  final List<String>? env;

  /// The registration order priority.
  final int? order;

  /// Optional GetIt scope name.
  final String? getItScope;

  /// Whether this singleton signals ready when initialized.
  final bool? signalsReady;

  /// Dependencies that must be initialized before this singleton.
  final List<Type>? dependsOn;

  /// Optional dispose callback function or method name.
  final Function? dispose;

  /// Creates an [Injectable] annotation.
  const Injectable({
    this.scope = Scope.factory,
    this.as,
    this.env,
    this.order,
    this.getItScope,
    this.signalsReady,
    this.dependsOn,
    this.dispose,
  });
}

/// Marks a constructor or static/top-level method as the factory method to instantiate a dependency.
class FactoryMethod {
  const FactoryMethod();
}

/// Marks a class as an external module dependency provider.
///
/// Example:
/// ```dart
/// @ExternalModule()
/// abstract class ThirdPartyModule {}
/// ```
class ExternalModule {
  const ExternalModule();
}

/// Specifies explicit registration order priority.
class Order {
  final int position;
  const Order(this.position);
}

/// Marks an asynchronous dependency that must be awaited before registering.
class PreResolve {
  const PreResolve();
}
