/// Marks a class or factory method as a dependency eligible for injection.
class Injectable {
  /// The type to bind this dependency to in the service locator.
  final Type? as;

  /// The environments in which this dependency is active.
  final List<String>? env;

  /// The registration order priority.
  final int? order;

  /// Optional locator scope.
  final String? scope;

  /// Creates an [Injectable] annotation.
  const Injectable({this.as, this.env, this.order, this.scope});
}

/// Constant instance for [@injectable] annotation.
const injectable = Injectable();

/// Marks a class or factory method as a eager singleton dependency.
class Singleton extends Injectable {
  /// Whether this singleton signals ready when initialized.
  final bool? signalsReady;

  /// Dependencies that must be initialized before this singleton.
  final List<Type>? dependsOn;

  /// Optional dispose callback function or method name.
  final Function? dispose;

  /// Creates a [Singleton] annotation.
  const Singleton({
    super.as,
    super.env,
    super.order,
    super.scope,
    this.signalsReady,
    this.dependsOn,
    this.dispose,
  });
}

/// Constant instance for [@singleton] annotation.
const singleton = Singleton();

/// Marks a class or factory method as a lazy singleton dependency.
class LazySingleton extends Injectable {
  /// Optional dispose callback function or method name.
  final Function? dispose;

  /// Creates a [LazySingleton] annotation.
  const LazySingleton({
    super.as,
    super.env,
    super.order,
    super.scope,
    this.dispose,
  });
}

/// Constant instance for [@lazySingleton] annotation.
const lazySingleton = LazySingleton();

/// Marks a constructor or static/top-level method as the factory method to instantiate a dependency.
class FactoryMethod {
  const FactoryMethod();
}

/// Constant instance for [@factoryMethod] annotation.
const factoryMethod = FactoryMethod();

/// Marks a class as a module providing third-party dependencies via getters or methods.
class Module {
  const Module();
}

/// Constant instance for [@module] annotation.
const module = Module();

/// Marks a class as a third-party dependency provider module (alias for [Module]).
class ThirdParty extends Module {
  const ThirdParty();
}

/// Constant instance for [@thirdParty] annotation.
const thirdParty = ThirdParty();

/// Specifies explicit registration order priority.
class Order {
  final int position;
  const Order(this.position);
}

/// Marks an asynchronous dependency that must be awaited before registering.
class PreResolve {
  const PreResolve();
}

/// Constant instance for [@preResolve] annotation.
const preResolve = PreResolve();
