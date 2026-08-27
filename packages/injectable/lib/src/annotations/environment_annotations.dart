/// Annotates a class or method to restrict its registration to specific environments.
class Environment {
  /// The environment name.
  final String name;

  /// Creates an [Environment] annotation.
  const Environment(this.name);

  /// Predefined development environment name.
  static const dev = 'dev';

  /// Predefined production environment name.
  static const prod = 'prod';

  /// Predefined testing environment name.
  static const test = 'test';
}

/// Constant annotation for development environment.
const dev = Environment(Environment.dev);

/// Constant annotation for production environment.
const prod = Environment(Environment.prod);

/// Constant annotation for testing environment.
const test = Environment(Environment.test);
