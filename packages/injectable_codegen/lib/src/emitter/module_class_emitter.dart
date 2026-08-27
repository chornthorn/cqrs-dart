import '../model/dependency_info.dart';
import '../model/import_alias_registry.dart';
import '../model/module_info.dart';
import 'registration_emitter.dart';

/// Emits [MicroPackageModule] classes and [GetIt] initialization extension methods.
class ModuleClassEmitter {
  const ModuleClassEmitter({
    this.registrationEmitter = const RegistrationEmitter(),
  });

  final RegistrationEmitter registrationEmitter;

  /// Writes a [MicroPackageModule] subclass.
  void writeMicroPackageModule(
    StringBuffer buffer, {
    required String moduleClassName,
    required List<DependencyInfo> dependencies,
    required List<DiscoveredModule> subModules,
    required ImportAliasRegistry aliasRegistry,
  }) {
    final hasAsync = dependencies.any((d) => d.isAsync);

    buffer.writeln('class $moduleClassName extends _i1.MicroPackageModule {');
    buffer.writeln('  @override');
    if (hasAsync) {
      buffer.writeln('  Future<void> init(_i1.GetItHelper gh) async {');
    } else {
      buffer.writeln('  void init(_i1.GetItHelper gh) {');
    }

    // Emit dependency registrations
    registrationEmitter.writeRegistrations(
      buffer,
      dependencies: dependencies,
      aliasRegistry: aliasRegistry,
      helperName: 'gh',
    );

    // Emit sub-module initializations
    for (final sub in subModules) {
      final formattedSub =
          aliasRegistry.formatTypeName(sub.moduleClassName, sub.packageUri);
      buffer.writeln('    gh.initMicroPackage($formattedSub());');
    }

    buffer.writeln('  }');
    buffer.writeln('}');
  }

  /// Writes the [GetIt] initialization extension.
  void writeGetItExtension(
    StringBuffer buffer, {
    required String initializerName,
    required String? moduleClassName,
    required bool isMicroPackage,
    required bool useMicroPackage,
    required List<DependencyInfo> dependencies,
    required List<DiscoveredModule> subModules,
    required ImportAliasRegistry aliasRegistry,
  }) {
    final hasAsync = dependencies.any((d) => d.isAsync);
    final returnType = hasAsync ? 'Future<_i2.GetIt>' : '_i2.GetIt';
    final asyncModifier = hasAsync ? 'async ' : '';
    final awaitModifier = hasAsync ? 'await ' : '';

    final extensionName = isMicroPackage && moduleClassName != null
        ? '${moduleClassName}X'
        : 'GetItInjectableX';

    buffer.writeln('extension $extensionName on _i2.GetIt {');
    buffer.writeln('  $returnType $initializerName({');
    buffer.writeln('    String? environment,');
    buffer.writeln('    _i1.EnvironmentFilter? environmentFilter,');
    buffer.writeln('  }) $asyncModifier{');
    buffer.writeln('    final gh = _i1.GetItHelper(');
    buffer.writeln('      this,');
    buffer.writeln('      environment: environment,');
    buffer.writeln('      environmentFilter: environmentFilter,');
    buffer.writeln('    );');

    if (isMicroPackage && moduleClassName != null) {
      buffer.writeln('    $awaitModifier$moduleClassName().init(gh);');
    } else if (useMicroPackage) {
      // Root compositor mode
      for (final sub in subModules) {
        final formattedSub =
            aliasRegistry.formatTypeName(sub.moduleClassName, sub.packageUri);
        buffer.writeln('    $awaitModifier gh.initMicroPackage($formattedSub());');
      }

      // Direct dependencies in root if any
      if (dependencies.isNotEmpty) {
        registrationEmitter.writeRegistrations(
          buffer,
          dependencies: dependencies,
          aliasRegistry: aliasRegistry,
          helperName: 'gh',
        );
      }
    } else {
      // Monolithic root mode
      registrationEmitter.writeRegistrations(
        buffer,
        dependencies: dependencies,
        aliasRegistry: aliasRegistry,
        helperName: 'gh',
      );
    }

    buffer.writeln('    return this;');
    buffer.writeln('  }');
    buffer.writeln('}');
  }
}
