import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations/cqrs_annotations.dart';
import '../model/module_info.dart';

/// Parses `@CqrsInit` or `@CqrsMicroPackage` annotations from libraries into [CqrsGeneratorConfig].
class AnnotationParser {
  const AnnotationParser();

  static const anyChecker = TypeChecker.any([
    TypeChecker.typeNamed(CqrsInit),
    TypeChecker.typeNamed(CqrsMicroPackage),
  ]);

  static const initChecker = TypeChecker.typeNamed(CqrsInit);

  /// Parses the configuration from the annotated [library].
  CqrsGeneratorConfig? parse(LibraryReader library) {
    final annotated = library.annotatedWith(anyChecker);
    if (annotated.isEmpty) return null;

    final annotationTypeName =
        annotated.first.annotation.objectValue.type?.element?.name ?? '';
    final bool isMicroPackage = annotationTypeName == 'CqrsMicroPackage';

    final annotation = annotated.first.annotation;
    final moduleName = annotation.peek('moduleName')?.stringValue;
    final customMethodName = annotation.peek('methodName')?.stringValue;
    final customExtensionName = annotation.peek('extensionName')?.stringValue;
    final customModuleClassName =
        annotation.peek('moduleClassName')?.stringValue;
    final includeDefaults =
        annotation.peek('includeDefaultFactories')?.boolValue ?? true;
    var useMicroPackage =
        annotation.peek('useMicroPackage')?.boolValue ?? isMicroPackage;
    var generateInjectable =
        annotation.peek('generateInjectable')?.boolValue ?? false;

    // Read manual list of CqrsPackageModule types
    final moduleTypeNames = <String>[];
    final modulesReader = annotation.peek('modules');
    if (modulesReader?.listValue != null) {
      for (final obj in modulesReader!.listValue) {
        final name = obj.toTypeValue()?.getDisplayString().replaceAll('?', '') ??
            obj.toTypeValue()?.element?.name;
        if (name != null && name != 'dynamic' && name != 'InvalidType') {
          moduleTypeNames.add(name);
        }
      }
    }

    // Fallback AST inspection
    if (moduleTypeNames.isEmpty || !useMicroPackage) {
      try {
        final session = library.element.session;
        final parsedLib = session.getParsedLibraryByElement(library.element);
        if (parsedLib is ParsedLibraryResult) {
          for (final unit in parsedLib.units) {
            for (final decl in unit.unit.declarations) {
              for (final ann in decl.metadata) {
                final annName = ann.name.name;
                if (annName == 'CqrsInit' || annName == 'CqrsMicroPackage') {
                  final args = ann.arguments?.arguments;
                  if (args != null) {
                    for (final arg in args) {
                      if (arg is NamedArgument) {
                        if (arg.name.lexeme == 'useMicroPackage') {
                          final expr = arg.argumentExpression;
                          if (expr is BooleanLiteral) {
                            useMicroPackage = expr.value;
                          }
                        } else if (arg.name.lexeme == 'modules') {
                          final expr = arg.argumentExpression;
                          if (expr is ListLiteral) {
                            for (final elem in expr.elements) {
                              final src = elem.toSource().trim();
                              if (src.isNotEmpty) {
                                moduleTypeNames.add(src);
                              }
                            }
                          }
                        } else if (arg.name.lexeme == 'generateInjectable') {
                          final expr = arg.argumentExpression;
                          if (expr is BooleanLiteral) {
                            generateInjectable = expr.value;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    final extensionName = (customExtensionName != null &&
            customExtensionName.isNotEmpty)
        ? customExtensionName
        : (moduleName != null && moduleName.isNotEmpty)
            ? 'AutoRegister${_capitalize(moduleName)}Cqrs'
            : 'AutoRegisterCqrs';

    final methodName = (customMethodName != null && customMethodName.isNotEmpty)
        ? customMethodName
        : (moduleName != null && moduleName.isNotEmpty)
            ? 'register${_capitalize(moduleName)}Handlers'
            : 'registerGeneratedHandlers';

    final moduleClassName = (customModuleClassName != null &&
            customModuleClassName.isNotEmpty)
        ? customModuleClassName
        : (moduleName != null && moduleName.isNotEmpty)
            ? '${_capitalize(moduleName)}CqrsModule'
            : 'GeneratedCqrsModule';

    return CqrsGeneratorConfig(
      isMicroPackage: isMicroPackage,
      useMicroPackage: useMicroPackage,
      generateInjectable: generateInjectable,
      includeDefaults: includeDefaults,
      extensionName: extensionName,
      methodName: methodName,
      moduleClassName: moduleClassName,
      manualModuleTypeNames: moduleTypeNames,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
