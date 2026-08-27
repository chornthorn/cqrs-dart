/// Filter to determine whether a dependency should be registered based on active environments.
abstract class EnvironmentFilter {
  /// Set of currently active environment names.
  final Set<String> environments;

  /// Creates an [EnvironmentFilter].
  const EnvironmentFilter(this.environments);

  /// Returns `true` if a dependency with [targetEnvironments] is eligible for registration.
  bool canRegister(Set<String> targetEnvironments);
}

/// Default filter that registers dependencies if their environment list is empty or intersects with active environments.
class NoEnvOrContains extends EnvironmentFilter {
  const NoEnvOrContains(super.environments);

  @override
  bool canRegister(Set<String> targetEnvironments) {
    if (targetEnvironments.isEmpty) return true;
    return targetEnvironments.any(environments.contains);
  }
}

/// Filter requiring that all specified target environments match active environments.
class NoEnvOrContainsAll extends EnvironmentFilter {
  const NoEnvOrContainsAll(super.environments);

  @override
  bool canRegister(Set<String> targetEnvironments) {
    if (targetEnvironments.isEmpty) return true;
    return environments.containsAll(targetEnvironments);
  }
}

/// Simple environment filter.
class SimpleEnvironmentFilter extends EnvironmentFilter {
  const SimpleEnvironmentFilter({required Set<String> environments})
      : super(environments);

  @override
  bool canRegister(Set<String> targetEnvironments) {
    if (targetEnvironments.isEmpty) return true;
    return targetEnvironments.any(environments.contains);
  }
}
