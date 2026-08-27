import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import '../model/dependency_info.dart';
import '../model/module_info.dart';
import '../parser/annotation_parser.dart';
import '../parser/dependency_parser.dart';

/// Boundary-aware directory scanner for Injectable micro-packages and modules.
class LibraryScanner {
  const LibraryScanner({this.parser = const DependencyParser()});

  final DependencyParser parser;

  static bool _isGenerated(AssetId asset) =>
      asset.path.endsWith('.config.dart') ||
      asset.path.endsWith('.injectable.dart');

  /// Checks whether root `@InjectableInit` exists in `lib/**.dart` with `useMicroPackage: true`.
  Future<bool> isMicroPackageGloballyEnabled(BuildStep buildStep) async {
    final allLibAssets =
        await buildStep.findAssets(Glob('lib/**.dart')).toList();
    for (final asset in allLibAssets) {
      if (_isGenerated(asset)) continue;
      try {
        if (!await buildStep.resolver.isLibrary(asset)) continue;
        final lib = await buildStep.resolver.libraryFor(asset);
        final reader = LibraryReader(lib);
        final initAnnotated =
            reader.annotatedWith(AnnotationParser.initChecker);
        for (final item in initAnnotated) {
          final annTypeName =
              item.annotation.objectValue.type?.element?.name ?? '';
          if (annTypeName == 'InjectableInit') {
            final useMicro =
                item.annotation.peek('useMicroPackage')?.boolValue ?? false;
            return useMicro;
          }
        }

        // Fallback AST inspection for @InjectableInit
        final session = lib.session;
        final parsed = session.getParsedLibraryByElement(lib);
        if (parsed is ParsedLibraryResult) {
          for (final unit in parsed.units) {
            for (final decl in unit.unit.declarations) {
              for (final meta in decl.metadata) {
                if (meta.name.name == 'InjectableInit') {
                  final args = meta.arguments?.arguments;
                  if (args != null) {
                    for (final arg in args) {
                      if (arg is NamedArgument &&
                          arg.name.lexeme == 'useMicroPackage') {
                        final expr = arg.argumentExpression;
                        if (expr is BooleanLiteral) {
                          return expr.value;
                        }
                      }
                    }
                  }
                  return false;
                }
              }
            }
          }
        }
      } catch (_) {}
    }
    return true; // Allow standalone micro-package generation if no root init is found
  }

  /// Extracts the module class name from an annotated [LibraryElement] or AST.
  String? findMicroPackageModuleClass(LibraryElement lib) {
    try {
      final reader = LibraryReader(lib);
      final annotated = reader.annotatedWith(AnnotationParser.anyChecker);
      if (annotated.isNotEmpty) {
        final ann = annotated.first.annotation;
        final typeName = ann.objectValue.type?.element?.name ?? '';
        final bool isMicro = typeName == 'InjectableMicroPackage';
        if (isMicro) {
          final customClassName =
              ann.peek('moduleClassName')?.stringValue;
          if (customClassName != null && customClassName.isNotEmpty) {
            return customClassName;
          }
          final modName = ann.peek('moduleName')?.stringValue;
          if (modName != null && modName.isNotEmpty) {
            return '${_capitalize(modName)}InjectableModule';
          }
          return 'GeneratedInjectableModule';
        }
      }
    } catch (_) {}

    // Fallback AST inspection
    try {
      final session = lib.session;
      final parsedLib = session.getParsedLibraryByElement(lib);
      if (parsedLib is ParsedLibraryResult) {
        for (final unit in parsedLib.units) {
          for (final decl in unit.unit.declarations) {
            for (final ann in decl.metadata) {
              final annName = ann.name.name;
              if (annName == 'InjectableMicroPackage') {
                String? modName;
                String? customClass;
                final args = ann.arguments?.arguments;
                if (args != null) {
                  for (final arg in args) {
                    if (arg is NamedArgument) {
                      if (arg.name.lexeme == 'moduleName') {
                        modName = arg.argumentExpression
                            .toSource()
                            .replaceAll("'", '')
                            .replaceAll('"', '');
                      } else if (arg.name.lexeme == 'moduleClassName') {
                        customClass = arg.argumentExpression
                            .toSource()
                            .replaceAll("'", '')
                            .replaceAll('"', '');
                      }
                    }
                  }
                }
                if (customClass != null && customClass.isNotEmpty) {
                  return customClass;
                }
                if (modName != null && modName.isNotEmpty) {
                  return '${_capitalize(modName)}InjectableModule';
                }
                return 'GeneratedInjectableModule';
              }
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Converts an [AssetId] into its generated `.config.dart` package URI string.
  static Uri assetToConfigPackageUri(AssetId assetId) {
    var path = assetId.path.startsWith('lib/')
        ? assetId.path.substring(4)
        : assetId.path;
    if (path.endsWith('.dart') && !path.endsWith('.config.dart')) {
      path = '${path.substring(0, path.length - 5)}.config.dart';
    }
    return Uri.parse('package:${assetId.package}/$path');
  }

  /// Scans the directory of [targetAsset], respecting nested micro-package boundaries.
  Future<ModuleScanResult> scanDirectory({
    required BuildStep buildStep,
    required AssetId targetAsset,
    required bool isMicroPackage,
    required bool useMicroPackage,
  }) async {
    final targetDirPath = p.dirname(targetAsset.path);
    final bool isRootCompositor = !isMicroPackage && useMicroPackage;
    final bool isMonolithicRoot = !isMicroPackage && !useMicroPackage;

    final searchGlob = (isRootCompositor || isMonolithicRoot)
        ? Glob('lib/**.dart')
        : Glob('$targetDirPath/**.dart');

    final allAssets = await buildStep.findAssets(searchGlob).toList();
    final excludedDirs = <String>{};
    final discoveredSubModules = <DiscoveredModule>[];

    // 1. Discover micro-package boundaries only when micro-packages are active
    if (isRootCompositor || isMicroPackage) {
      for (final asset in allAssets) {
        if (asset == targetAsset || _isGenerated(asset)) continue;

        try {
          if (!await buildStep.resolver.isLibrary(asset)) continue;
          final lib = await buildStep.resolver.libraryFor(asset);
          final moduleClassName = findMicroPackageModuleClass(lib);
          if (moduleClassName != null) {
            final assetDir = p.dirname(asset.path);
            final module = DiscoveredModule(
              moduleClassName: moduleClassName,
              assetId: asset,
              directory: assetDir,
              packageUri: assetToConfigPackageUri(asset),
            );
            discoveredSubModules.add(module);

            // Exclude micro-package folders from parent scanning
            if (assetDir != targetDirPath) {
              excludedDirs.add(assetDir);
            }
          }
        } catch (_) {}
      }
    }

    // 2. Scan dependencies within boundary
    final dependencies = <DependencyInfo>[];
    final typeUris = <Uri>{};
    final visitedClassNames = <String>{};

    for (final asset in allAssets) {
      if (_isGenerated(asset)) continue;

      final filePath = asset.path;
      final fileDir = p.dirname(filePath);
      final isExcluded = excludedDirs.any(
        (exDir) => fileDir == exDir || p.isWithin(exDir, filePath),
      );
      if (isExcluded) continue;

      try {
        if (!await buildStep.resolver.isLibrary(asset)) continue;
        final lib = await buildStep.resolver.libraryFor(asset);

        for (final c in lib.classes) {
          final name = c.name;
          if (name != null && visitedClassNames.add(name)) {
            final parsedDeps = parser.parseClass(c);
            for (final dep in parsedDeps) {
              dependencies.add(dep);

              if (dep.classUri != null &&
                  dep.classUri!.scheme != 'dart' &&
                  !dep.classUri!.toString().startsWith('package:injectable/')) {
                typeUris.add(dep.classUri!);
              }
              if (dep.boundTypeUri != null &&
                  dep.boundTypeUri!.scheme != 'dart' &&
                  !dep.boundTypeUri!.toString().startsWith('package:injectable/')) {
                typeUris.add(dep.boundTypeUri!);
              }
              if (dep.moduleUri != null &&
                  dep.moduleUri!.scheme != 'dart' &&
                  !dep.moduleUri!.toString().startsWith('package:injectable/')) {
                typeUris.add(dep.moduleUri!);
              }
              for (final p in dep.params) {
                if (p.typeUri != null &&
                    p.typeUri!.scheme != 'dart' &&
                    !p.typeUri!.toString().startsWith('package:injectable/')) {
                  typeUris.add(p.typeUri!);
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // Sort dependencies by order
    dependencies.sort((a, b) => a.order.compareTo(b.order));

    return ModuleScanResult(
      dependencies: dependencies,
      subModules: isRootCompositor ? discoveredSubModules : const [],
      typeUris: typeUris,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
