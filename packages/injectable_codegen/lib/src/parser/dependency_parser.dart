import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:injectable/injectable.dart';
import 'package:source_gen/source_gen.dart';

import '../model/dependency_info.dart';
import '../model/import_alias_registry.dart';

/// Parses dependency annotations and constructors from Dart classes.
class DependencyParser {
  const DependencyParser();

  static const injectableChecker = TypeChecker.typeNamed(Injectable);
  static const singletonChecker = TypeChecker.typeNamed(Singleton);
  static const lazySingletonChecker = TypeChecker.typeNamed(LazySingleton);
  static const moduleChecker = TypeChecker.typeNamed(Module);
  static const thirdPartyChecker = TypeChecker.typeNamed(ThirdParty);
  static const injectChecker = TypeChecker.typeNamed(Inject);
  static const factoryParamChecker = TypeChecker.typeNamed(FactoryParam);
  static const factoryMethodChecker = TypeChecker.typeNamed(FactoryMethod);
  static const preResolveChecker = TypeChecker.typeNamed(PreResolve);
  static const envChecker = TypeChecker.typeNamed(Environment);
  static const orderChecker = TypeChecker.typeNamed(Order);

  /// Parses a class element into one or more [DependencyInfo] entries.
  List<DependencyInfo> parseClass(ClassElement element) {
    if (moduleChecker.hasAnnotationOfExact(element) ||
        thirdPartyChecker.hasAnnotationOfExact(element) ||
        moduleChecker.hasAnnotationOf(element)) {
      return _parseModule(element);
    }

    final dependency = _parseInjectableClass(element);
    if (dependency != null) {
      return [dependency];
    }
    return const [];
  }

  DependencyInfo? _parseInjectableClass(ClassElement element) {
    final annotation = _getInjectableAnnotation(element);
    if (annotation == null) return null;

    final classUri = ImportAliasRegistry.getLibraryUri(element);
    final kind = _getDependencyKind(annotation);
    final environments = _extractEnvironments(element, annotation);
    final order = _extractOrder(element, annotation);
    final boundType = _extractBoundType(element, annotation);
    final boundTypeUri = _extractBoundTypeUri(annotation) ?? classUri;
    final isAsync = _isAsyncClass(element);
    final instanceName = _extractInstanceName(element);
    final signalsReady = annotation.peek('signalsReady')?.boolValue;
    final dependsOn = _extractDependsOn(annotation);
    final disposeMethod = _extractDisposeMethod(element, annotation);

    // Find constructor or factory method
    final constructor = _findTargetConstructor(element);
    final params = constructor != null
        ? _parseParameters(constructor.formalParameters)
        : const <InjectedParam>[];

    final cName = (constructor != null &&
            constructor.name != null &&
            constructor.name!.isNotEmpty &&
            constructor.name != 'new')
        ? constructor.name
        : null;

    return DependencyInfo(
      className: element.name ?? '',
      boundType: boundType,
      kind: kind,
      isAsync: isAsync,
      environments: environments,
      order: order,
      instanceName: instanceName,
      params: params,
      constructorName: cName,
      disposeMethodName: disposeMethod,
      signalsReady: signalsReady,
      dependsOn: dependsOn,
      classUri: classUri,
      boundTypeUri: boundTypeUri,
    );
  }

  List<DependencyInfo> _parseModule(ClassElement element) {
    final list = <DependencyInfo>[];
    final moduleClassName = element.name ?? '';
    final moduleUri = ImportAliasRegistry.getLibraryUri(element);
    final isAbstract = element.isAbstract;

    // Parse getters and methods
    for (final getter in element.getters) {
      if (getter.isPublic) {
        final ann = _getInjectableAnnotation(getter) ??
            _getInjectableAnnotation(element);
        final kind =
            ann != null ? _getDependencyKind(ann) : DependencyKind.factory;
        final returnType = getter.returnType;
        final typeName = _cleanTypeName(returnType.getDisplayString());
        final environments = ann != null
            ? _extractEnvironments(getter, ann)
            : const <String>{};
        final instanceName = _extractInstanceName(getter);
        final isAsync = returnType.isDartAsyncFuture;
        final actualType = isAsync && returnType is ParameterizedType
            ? _cleanTypeName(
                returnType.typeArguments.first.getDisplayString())
            : typeName;

        final typeUri = ImportAliasRegistry.getLibraryUri(
            isAsync && returnType is ParameterizedType
                ? returnType.typeArguments.first.element
                : returnType.element);

        list.add(DependencyInfo(
          className: actualType,
          boundType: actualType,
          kind: kind,
          isAsync: isAsync || preResolveChecker.hasAnnotationOfExact(getter),
          environments: environments,
          instanceName: instanceName,
          moduleClassName: moduleClassName,
          moduleMemberName: getter.name,
          moduleUri: moduleUri,
          isModuleMethod: false,
          isModuleClassAbstract: isAbstract,
          classUri: typeUri ?? moduleUri,
          boundTypeUri: typeUri,
        ));
      }
    }

    for (final method in element.methods) {
      if (method.isPublic && !method.isStatic) {
        final ann = _getInjectableAnnotation(method) ??
            _getInjectableAnnotation(element);
        final kind =
            ann != null ? _getDependencyKind(ann) : DependencyKind.factory;
        final returnType = method.returnType;
        final typeName = _cleanTypeName(returnType.getDisplayString());
        final isAsync = returnType.isDartAsyncFuture;
        final actualType = isAsync && returnType is ParameterizedType
            ? _cleanTypeName(
                returnType.typeArguments.first.getDisplayString())
            : typeName;

        final typeUri = ImportAliasRegistry.getLibraryUri(
            isAsync && returnType is ParameterizedType
                ? returnType.typeArguments.first.element
                : returnType.element);

        final params = _parseParameters(method.formalParameters);
        final environments =
            ann != null ? _extractEnvironments(method, ann) : const <String>{};
        final instanceName = _extractInstanceName(method);

        list.add(DependencyInfo(
          className: actualType,
          boundType: actualType,
          kind: kind,
          isAsync: isAsync || preResolveChecker.hasAnnotationOfExact(method),
          environments: environments,
          instanceName: instanceName,
          params: params,
          moduleClassName: moduleClassName,
          moduleMemberName: method.name,
          moduleUri: moduleUri,
          isModuleMethod: true,
          isModuleClassAbstract: isAbstract,
          classUri: typeUri ?? moduleUri,
          boundTypeUri: typeUri,
        ));
      }
    }

    return list;
  }

  ConstantReader? _getInjectableAnnotation(Element element) {
    if (lazySingletonChecker.hasAnnotationOfExact(element)) {
      return ConstantReader(
          lazySingletonChecker.firstAnnotationOfExact(element));
    }
    if (singletonChecker.hasAnnotationOfExact(element)) {
      return ConstantReader(singletonChecker.firstAnnotationOfExact(element));
    }
    if (injectableChecker.hasAnnotationOfExact(element)) {
      return ConstantReader(injectableChecker.firstAnnotationOfExact(element));
    }
    // Also check subtypes
    final ann = injectableChecker.firstAnnotationOf(element);
    if (ann != null) return ConstantReader(ann);
    return null;
  }

  DependencyKind _getDependencyKind(ConstantReader annotation) {
    final typeName = annotation.objectValue.type?.element?.name ?? '';
    if (typeName == 'Singleton') return DependencyKind.singleton;
    if (typeName == 'LazySingleton') return DependencyKind.lazySingleton;
    return DependencyKind.factory;
  }

  Set<String> _extractEnvironments(
      Element element, ConstantReader annotation) {
    final envs = <String>{};
    final envList = annotation.peek('env')?.listValue;
    if (envList != null) {
      for (final e in envList) {
        final val = e.toStringValue();
        if (val != null) envs.add(val);
      }
    }

    for (final ann in element.metadata.annotations) {
      final obj = ann.computeConstantValue();
      if (obj != null && obj.type?.element?.name == 'Environment') {
        final name = obj.getField('name')?.toStringValue();
        if (name != null) envs.add(name);
      }
    }
    return envs;
  }

  int _extractOrder(Element element, ConstantReader annotation) {
    final orderField = annotation.peek('order')?.intValue;
    if (orderField != null) return orderField;

    for (final ann in element.metadata.annotations) {
      final obj = ann.computeConstantValue();
      if (obj != null && obj.type?.element?.name == 'Order') {
        final pos = obj.getField('position')?.toIntValue();
        if (pos != null) return pos;
      }
    }
    return 0;
  }

  String _extractBoundType(ClassElement element, ConstantReader annotation) {
    final asType = annotation.peek('as')?.typeValue;
    if (asType != null && asType is! DynamicType) {
      return _cleanTypeName(asType.getDisplayString());
    }
    return element.name ?? '';
  }

  Uri? _extractBoundTypeUri(ConstantReader annotation) {
    final asType = annotation.peek('as')?.typeValue;
    if (asType != null && asType is! DynamicType) {
      return ImportAliasRegistry.getLibraryUri(asType.element);
    }
    return null;
  }

  bool _isAsyncClass(ClassElement element) {
    if (preResolveChecker.hasAnnotationOfExact(element)) return true;
    for (final c in element.constructors) {
      if (factoryMethodChecker.hasAnnotationOfExact(c) ||
          preResolveChecker.hasAnnotationOfExact(c)) {
        return true;
      }
    }
    for (final m in element.methods) {
      if (factoryMethodChecker.hasAnnotationOfExact(m) &&
          (m.returnType.isDartAsyncFuture ||
              preResolveChecker.hasAnnotationOfExact(m))) {
        return true;
      }
    }
    return false;
  }

  String? _extractInstanceName(Element element) {
    for (final ann in element.metadata.annotations) {
      final obj = ann.computeConstantValue();
      final typeName = obj?.type?.element?.name;
      if (typeName == 'Inject') {
        return obj?.getField('tag')?.toStringValue();
      }
    }
    return null;
  }

  List<String> _extractDependsOn(ConstantReader annotation) {
    final list = <String>[];
    final depends = annotation.peek('dependsOn')?.listValue;
    if (depends != null) {
      for (final d in depends) {
        final typeVal = d.toTypeValue();
        if (typeVal != null) {
          list.add(_cleanTypeName(typeVal.getDisplayString()));
        }
      }
    }
    return list;
  }

  String? _extractDisposeMethod(
      ClassElement element, ConstantReader annotation) {
    final disposeFunc = annotation.peek('dispose');
    if (disposeFunc != null && disposeFunc.isSymbol) {
      return disposeFunc.symbolValue.toString();
    }
    for (final m in element.methods) {
      for (final ann in m.metadata.annotations) {
        if (ann.computeConstantValue()?.type?.element?.name ==
            'DisposeMethod') {
          return m.name;
        }
      }
    }
    return null;
  }

  ConstructorElement? _findTargetConstructor(ClassElement element) {
    for (final c in element.constructors) {
      if (factoryMethodChecker.hasAnnotationOfExact(c)) {
        return c;
      }
    }
    // Return unnamed or first constructor
    return element.unnamedConstructor ??
        (element.constructors.isNotEmpty ? element.constructors.first : null);
  }

  List<InjectedParam> _parseParameters(
      List<FormalParameterElement> parameters) {
    final list = <InjectedParam>[];
    for (final p in parameters) {
      final isFactoryParam = factoryParamChecker.hasAnnotationOfExact(p);
      String? instanceName;
      for (final ann in p.metadata.annotations) {
        final obj = ann.computeConstantValue();
        final typeName = obj?.type?.element?.name;
        if (typeName == 'Inject') {
          instanceName = obj?.getField('tag')?.toStringValue();
        }
      }

      final typeUri = ImportAliasRegistry.getLibraryUri(p.type.element);

      list.add(InjectedParam(
        name: p.name ?? '',
        typeName: _cleanTypeName(p.type.getDisplayString()),
        isNamed: p.isNamed,
        isRequired: p.isRequired,
        isFactoryParam: isFactoryParam,
        instanceName: instanceName,
        typeUri: typeUri,
      ));
    }
    return list;
  }

  String _cleanTypeName(String s) => s.replaceAll('?', '');
}
