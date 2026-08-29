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
