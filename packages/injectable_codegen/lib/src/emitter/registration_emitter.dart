import '../model/dependency_info.dart';
import '../model/import_alias_registry.dart';

/// Emits dependency registration statements using [GetItHelper].
class RegistrationEmitter {
  const RegistrationEmitter();

  /// Writes dependency registrations inside a registration body.
  void writeRegistrations(
    StringBuffer buffer, {
    required List<DependencyInfo> dependencies,
    required ImportAliasRegistry aliasRegistry,
    String helperName = 'gh',
  }) {
    // Instantiate module instances if needed
    final moduleMap = <String, DependencyInfo>{};
    for (final dep in dependencies) {
      if (dep.moduleClassName != null) {
        moduleMap[dep.moduleClassName!] = dep;
      }
    }

    for (final entry in moduleMap.entries) {
      final modName = entry.key;
      final dep = entry.value;
      final varName = _uncapitalize(modName);

      if (dep.isModuleClassAbstract) {
        buffer.writeln('    final $varName = _\$$modName();');
      } else {
        final formattedMod =
            aliasRegistry.formatTypeName(modName, dep.moduleUri ?? dep.classUri);
        buffer.writeln('    final $varName = $formattedMod();');
      }
    }

    for (final dep in dependencies) {
      final boundType =
          aliasRegistry.formatTypeName(dep.boundType, dep.boundTypeUri);
      final implType =
          aliasRegistry.formatTypeName(dep.className, dep.classUri);

      final envArgs = dep.environments.isNotEmpty
          ? ", registerFor: {${dep.environments.map((e) => "'$e'").join(', ')}}"
          : '';
      final nameArgs = dep.instanceName != null
          ? ", instanceName: '${dep.instanceName}'"
          : '';
      final signalsReadyArgs =
          dep.signalsReady != null ? ", signalsReady: ${dep.signalsReady}" : '';
      final disposeArgs = dep.disposeMethodName != null
          ? ", dispose: (i) => i.${dep.disposeMethodName}()"
          : '';

      final isAsync = dep.isAsync;
      final factoryParams = dep.factoryParams;

      if (dep.moduleClassName != null) {
        // Module member registration
        final modVar = _uncapitalize(dep.moduleClassName!);
        final memberCall = dep.isModuleMethod
            ? '$modVar.${dep.moduleMemberName}(${_buildParamCalls(dep.injectedParams, aliasRegistry, helperName)})'
            : '$modVar.${dep.moduleMemberName}';

        switch (dep.kind) {
          case DependencyKind.singleton:
            if (isAsync) {
              buffer.writeln(
                  '    await $helperName.singletonAsync<$boundType>(() => $memberCall$nameArgs$signalsReadyArgs$disposeArgs$envArgs);');
            } else {
              buffer.writeln(
                  '    $helperName.singleton<$boundType>($memberCall$nameArgs$signalsReadyArgs$disposeArgs$envArgs);');
            }
            break;
          case DependencyKind.lazySingleton:
            buffer.writeln(
                '    $helperName.lazySingleton<$boundType>(() => $memberCall$nameArgs$disposeArgs$envArgs);');
            break;
          case DependencyKind.factory:
          case DependencyKind.moduleMember:
            buffer.writeln(
                '    $helperName.factory<$boundType>(() => $memberCall$nameArgs$envArgs);');
            break;
        }
      } else {
        // Standard class registration
        final constructorPrefix = dep.constructorName != null
            ? '$implType.${dep.constructorName}'
            : implType;

        if (factoryParams.isNotEmpty) {
          // factory with param
          final p1Type = factoryParams.isNotEmpty
              ? aliasRegistry.formatTypeName(
                  factoryParams[0].typeName, factoryParams[0].typeUri)
              : 'dynamic';
          final p2Type = factoryParams.length > 1
              ? aliasRegistry.formatTypeName(
                  factoryParams[1].typeName, factoryParams[1].typeUri)
              : 'dynamic';

          final paramNames = factoryParams.map((p) => p.name).join(', ');
          final invocation = _buildConstructorInvocation(
            constructorPrefix,
            dep.params,
            aliasRegistry,
            helperName,
          );

          buffer.writeln(
              '    $helperName.factoryWithParam<$boundType, $p1Type, $p2Type>(($paramNames, _) => $invocation$nameArgs$envArgs);');
        } else {
          final invocation = _buildConstructorInvocation(
            constructorPrefix,
            dep.params,
            aliasRegistry,
            helperName,
          );

          switch (dep.kind) {
            case DependencyKind.singleton:
              if (isAsync) {
                buffer.writeln(
                    '    await $helperName.singletonAsync<$boundType>(() => $invocation$nameArgs$signalsReadyArgs$disposeArgs$envArgs);');
              } else {
                buffer.writeln(
                    '    $helperName.singleton<$boundType>($invocation$nameArgs$signalsReadyArgs$disposeArgs$envArgs);');
              }
              break;
            case DependencyKind.lazySingleton:
              buffer.writeln(
                  '    $helperName.lazySingleton<$boundType>(() => $invocation$nameArgs$disposeArgs$envArgs);');
              break;
            case DependencyKind.factory:
            case DependencyKind.moduleMember:
              buffer.writeln(
                  '    $helperName.factory<$boundType>(() => $invocation$nameArgs$envArgs);');
              break;
          }
        }
      }
    }
  }

  /// Writes concrete module subclass implementations for abstract modules.
  void writeAbstractModuleClasses(
    StringBuffer buffer, {
    required List<DependencyInfo> dependencies,
    required ImportAliasRegistry aliasRegistry,
  }) {
    final abstractModules = <String, DependencyInfo>{};
    for (final dep in dependencies) {
      if (dep.moduleClassName != null && dep.isModuleClassAbstract) {
        abstractModules[dep.moduleClassName!] = dep;
      }
    }

    for (final entry in abstractModules.entries) {
      final modName = entry.key;
      final dep = entry.value;
      final formattedParent =
          aliasRegistry.formatTypeName(modName, dep.moduleUri ?? dep.classUri);
      buffer.writeln();
      buffer.writeln('class _\$$modName extends $formattedParent {}');
    }
  }

  String _buildConstructorInvocation(
    String target,
    List<InjectedParam> params,
    ImportAliasRegistry aliasRegistry,
    String helperName,
  ) {
    if (params.isEmpty) return '$target()';

    final posArgs = <String>[];
    final namedArgs = <String>[];

    for (final p in params) {
      final formattedType =
          aliasRegistry.formatTypeName(p.typeName, p.typeUri);
      final instName =
          p.instanceName != null ? "instanceName: '${p.instanceName}'" : '';
      final expr =
          p.isFactoryParam ? p.name : '$helperName<$formattedType>($instName)';

      if (p.isNamed) {
        namedArgs.add('${p.name}: $expr');
      } else {
        posArgs.add(expr);
      }
    }

    final allArgs = [...posArgs, ...namedArgs].join(', ');
    return '$target($allArgs)';
  }

  String _buildParamCalls(
    List<InjectedParam> params,
    ImportAliasRegistry aliasRegistry,
    String helperName,
  ) {
    final posArgs = <String>[];
    final namedArgs = <String>[];

    for (final p in params) {
      final formattedType =
          aliasRegistry.formatTypeName(p.typeName, p.typeUri);
      final instName =
          p.instanceName != null ? "instanceName: '${p.instanceName}'" : '';
      final expr = '$helperName<$formattedType>($instName)';

      if (p.isNamed) {
        namedArgs.add('${p.name}: $expr');
      } else {
        posArgs.add(expr);
      }
    }

    return [...posArgs, ...namedArgs].join(', ');
  }

  static String _uncapitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }
}
