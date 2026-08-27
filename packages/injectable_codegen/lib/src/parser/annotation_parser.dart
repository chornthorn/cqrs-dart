import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:injectable/injectable.dart';
import 'package:source_gen/source_gen.dart';

import '../model/module_info.dart';

/// Parses `@InjectableInit` or `@InjectableMicroPackage` annotations from libraries into [InjectableConfig].
class AnnotationParser {
  const AnnotationParser();

  static const anyChecker = TypeChecker.any([
    TypeChecker.typeNamed(InjectableInit),
    TypeChecker.typeNamed(InjectableMicroPackage),
  ]);

  static const initChecker = TypeChecker.typeNamed(InjectableInit);

  /// Parses configuration from the annotated [library].
  InjectableConfig? parse(LibraryReader library) {
    final annotated = library.annotatedWith(anyChecker);
    if (annotated.isEmpty) return null;

    final annotationTypeName =
        annotated.first.annotation.objectValue.type?.element?.name ?? '';
    final bool isMicroPackage =
        annotationTypeName == 'InjectableMicroPackage';

    final annotation = annotated.first.annotation;
    final moduleName = annotation.peek('moduleName')?.stringValue;
    final initializerName =
        annotation.peek('initializerName')?.stringValue ?? 'init';
    final asExtension =
        annotation.peek('asExtension')?.boolValue ?? true;
    final preferRelativeImports =
        annotation.peek('preferRelativeImports')?.boolValue ?? true;
    final customModuleClassName =
        annotation.peek('moduleClassName')?.stringValue;
    var useMicroPackage =
        annotation.peek('useMicroPackage')?.boolValue ?? isMicroPackage;

    // Read manual list of MicroPackageModule types
    final moduleTypeNames = <String>[];
    final modulesReader = annotation.peek('modules');
    if (modulesReader?.listValue != null) {
      for (final obj in modulesReader!.listValue) {
        final name =
            obj.toTypeValue()?.getDisplayString().replaceAll('?', '') ??
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
                if (annName == 'InjectableInit' ||
                    annName == 'InjectableMicroPackage') {
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

    final moduleClassName = (customModuleClassName != null &&
            customModuleClassName.isNotEmpty)
        ? customModuleClassName
        : (moduleName != null && moduleName.isNotEmpty)
            ? '${_capitalize(moduleName)}InjectableModule'
            : 'GeneratedInjectableModule';

    return InjectableConfig(
      isMicroPackage: isMicroPackage,
      useMicroPackage: useMicroPackage,
      initializerName: initializerName,
      asExtension: asExtension,
      preferRelativeImports: preferRelativeImports,
      moduleClassName: moduleClassName,
      moduleName: moduleName,
      manualModuleTypeNames: moduleTypeNames,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
