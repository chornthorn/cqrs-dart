/// Represents the lifecycle/kind of a dependency.
enum DependencyKind {
  factory,
  singleton,
  lazySingleton,
  moduleMember,
}

/// Metadata about a single constructor or method parameter.
class InjectedParam {
  final String name;
  final String typeName;
  final bool isNamed;
  final bool isRequired;
  final bool isFactoryParam;
  final String? instanceName;
  final Uri? typeUri;

  const InjectedParam({
    required this.name,
    required this.typeName,
    this.isNamed = false,
    this.isRequired = false,
    this.isFactoryParam = false,
    this.instanceName,
    this.typeUri,
  });
}

/// Metadata describing a registered injectable dependency.
class DependencyInfo {
  final String className;
  final String boundType;
  final DependencyKind kind;
  final bool isAsync;
  final Set<String> environments;
  final int order;
  final String? instanceName;
  final List<InjectedParam> params;
  final String? constructorName;
  final String? factoryMethodName;
  final String? moduleClassName;
  final String? moduleMemberName;
  final Uri? moduleUri;
  final bool isModuleMethod;
  final bool isModuleClassAbstract;
  final String? disposeMethodName;
  final bool? signalsReady;
  final List<String> dependsOn;
  final Uri? classUri;
  final Uri? boundTypeUri;

  const DependencyInfo({
    required this.className,
    required this.boundType,
    required this.kind,
    this.isAsync = false,
    this.environments = const {},
    this.order = 0,
    this.instanceName,
    this.params = const [],
    this.constructorName,
    this.factoryMethodName,
    this.moduleClassName,
    this.moduleMemberName,
    this.moduleUri,
    this.isModuleMethod = false,
    this.isModuleClassAbstract = false,
    this.disposeMethodName,
    this.signalsReady,
    this.dependsOn = const [],
    this.classUri,
    this.boundTypeUri,
  });

  /// Factory parameters for factoryWithParam
  List<InjectedParam> get factoryParams =>
      params.where((p) => p.isFactoryParam).toList();

  /// Injected dependencies from locator
  List<InjectedParam> get injectedParams =>
      params.where((p) => !p.isFactoryParam).toList();
}
