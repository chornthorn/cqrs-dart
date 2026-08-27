import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import '../model/handler_info.dart';
import '../model/import_alias_registry.dart';
import '../model/module_info.dart';
import '../parser/annotation_parser.dart';
import '../parser/handler_parser.dart';

/// Reusable boundary-aware directory scanner for code generators.
class LibraryScanner {
  const LibraryScanner({this.parser = const HandlerParser()});

  final HandlerParser parser;

  /// Checks if an asset is a generated output file that should be skipped during source scanning.
  static bool _isGenerated(AssetId asset) => asset.path.endsWith('.cqrs.dart');

  /// Checks whether `@CqrsInit` exists in `lib/**.dart` with `useMicroPackage: true`.
  /// If an `@CqrsInit` exists with `useMicroPackage: false` (or default false),
  /// returns `false` so individual micro-packages do not generate redundant files.
  Future<bool> isMicroPackageGloballyEnabled(BuildStep buildStep) async {
    final allLibAssets =
        await buildStep.findAssets(Glob('lib/**.dart')).toList();
    for (final asset in allLibAssets) {
      if (_isGenerated(asset)) {
        continue;
      }
      try {
        if (!await buildStep.resolver.isLibrary(asset)) continue;
        final lib = await buildStep.resolver.libraryFor(asset);
        final reader = LibraryReader(lib);
        final initAnnotated = reader.annotatedWith(AnnotationParser.initChecker);
        if (initAnnotated.isNotEmpty) {
          final ann = initAnnotated.first.annotation;
          final useMicro = ann.peek('useMicroPackage')?.boolValue ?? false;
          return useMicro;
        }

        // Fallback AST inspection for @CqrsInit
        final session = lib.session;
        final parsed = session.getParsedLibraryByElement(lib);
        if (parsed is ParsedLibraryResult) {
          for (final unit in parsed.units) {
            for (final decl in unit.unit.declarations) {
              for (final meta in decl.metadata) {
                if (meta.name.name == 'CqrsInit') {
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
    return true; // If no @CqrsInit is found, allow standalone micro-package generation
  }

  /// Checks whether `@CqrsInit` exists in `lib/**.dart` with `generateInjectable: true`.
  Future<bool> isInjectableGloballyEnabled(BuildStep buildStep) async {
    final allLibAssets =
        await buildStep.findAssets(Glob('lib/**.dart')).toList();
    for (final asset in allLibAssets) {
      if (_isGenerated(asset)) {
        continue;
      }
      try {
        if (!await buildStep.resolver.isLibrary(asset)) continue;
        final lib = await buildStep.resolver.libraryFor(asset);
        final reader = LibraryReader(lib);
        final initAnnotated = reader.annotatedWith(AnnotationParser.initChecker);
        if (initAnnotated.isNotEmpty) {
          final ann = initAnnotated.first.annotation;
          final genInjectable =
              ann.peek('generateInjectable')?.boolValue ?? false;
          return genInjectable;
        }

        // Fallback AST inspection for @CqrsInit
        final session = lib.session;
        final parsed = session.getParsedLibraryByElement(lib);
        if (parsed is ParsedLibraryResult) {
          for (final unit in parsed.units) {
            for (final decl in unit.unit.declarations) {
              for (final meta in decl.metadata) {
                if (meta.name.name == 'CqrsInit') {
                  final args = meta.arguments?.arguments;
                  if (args != null) {
                    for (final arg in args) {
                      if (arg is NamedArgument &&
                          arg.name.lexeme == 'generateInjectable') {
                        final expr = arg.argumentExpression;
                        if (expr is BooleanLiteral) {
                          return expr.value;
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
    return false;
  }

  /// Extracts the module class name from an annotated [LibraryElement] or AST.
  String? findMicroPackageModuleClass(LibraryElement lib) {
    // 1. Try via source_gen TypeChecker
    try {
      final reader = LibraryReader(lib);
      final annotated = reader.annotatedWith(AnnotationParser.anyChecker);
      if (annotated.isNotEmpty) {
        final ann = annotated.first.annotation;
        final typeName = ann.objectValue.type?.element?.name ?? '';
        final bool isMicro = typeName == 'CqrsMicroPackage';
        final bool useMicro = ann.peek('useMicroPackage')?.boolValue ?? isMicro;
        if (useMicro) {
          final customClassName = ann.peek('moduleClassName')?.stringValue;
          if (customClassName != null && customClassName.isNotEmpty) {
            return customClassName;
          }
          final modName = ann.peek('moduleName')?.stringValue;
          if (modName != null && modName.isNotEmpty) {
            return '${_capitalize(modName)}CqrsModule';
          }
          return 'GeneratedCqrsModule';
        }
      }
    } catch (_) {}

    // 2. Fallback via AST inspection
    try {
      final session = lib.session;
      final parsedLib = session.getParsedLibraryByElement(lib);
      if (parsedLib is ParsedLibraryResult) {
        for (final unit in parsedLib.units) {
          for (final decl in unit.unit.declarations) {
            for (final ann in decl.metadata) {
              final annName = ann.name.name;
              if (annName == 'CqrsMicroPackage' || annName == 'CqrsInit') {
                bool isMicro = annName == 'CqrsMicroPackage';
                String? modName;
                String? customClass;
                final args = ann.arguments?.arguments;
                if (args != null) {
                  for (final arg in args) {
                    if (arg is NamedArgument) {
                      if (arg.name.lexeme == 'useMicroPackage') {
                        final expr = arg.argumentExpression;
                        if (expr is BooleanLiteral) {
                          isMicro = expr.value;
                        }
                      } else if (arg.name.lexeme == 'moduleName') {
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
                if (isMicro) {
                  if (customClass != null && customClass.isNotEmpty) {
                    return customClass;
                  }
                  if (modName != null && modName.isNotEmpty) {
                    return '${_capitalize(modName)}CqrsModule';
                  }
                  return 'GeneratedCqrsModule';
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Converts an [AssetId] into its generated `.cqrs.dart` package URI string.
  static Uri assetToCqrsPackageUri(AssetId assetId) {
    var path = assetId.path.startsWith('lib/')
        ? assetId.path.substring(4)
        : assetId.path;
    if (path.endsWith('.dart') && !path.endsWith('.cqrs.dart')) {
      path = '${path.substring(0, path.length - 5)}.cqrs.dart';
    }
    return Uri.parse('package:${assetId.package}/$path');
  }

  /// Converts an [AssetId] into its absolute package URI string.
  static Uri assetToPackageUri(AssetId assetId) {
    final path = assetId.path.startsWith('lib/')
        ? assetId.path.substring(4)
        : assetId.path;
    return Uri.parse('package:${assetId.package}/$path');
  }

  /// Scans the directory of [targetAsset] using [buildStep], respecting nested
  /// `@CqrsMicroPackage` boundaries when [useMicroPackage] is true, or scanning all
  /// handlers when [useMicroPackage] is false (monolithic mode).
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
        if (asset == targetAsset || _isGenerated(asset)) {
          continue;
        }

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
              packageUri: assetToCqrsPackageUri(asset),
            );
            discoveredSubModules.add(module);

            // If this is a feature micro-package, exclude nested sub-package directories
            if (isMicroPackage && assetDir != targetDirPath) {
              excludedDirs.add(assetDir);
            }
          }
        } catch (_) {}
      }
    }

    if (isRootCompositor) {
      return ModuleScanResult(
        handlers: const [],
        typeUris: const {},
        subModules: discoveredSubModules,
      );
    }

    discoveredSubModules.clear();

    // 2. Scan handlers (in monolithic root mode, scans ALL files without exclusions;
    // in micro-package mode, scans only files belonging to this module's boundary)
    final handlers = <HandlerInfo>[];
    final typeUris = <Uri>{};
    final visitedClassNames = <String>{};

    for (final asset in allAssets) {
      if (asset == targetAsset || _isGenerated(asset)) {
        continue;
      }

      // Check if file is inside an excluded nested micro-package directory
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
            final info = parser.parseClass(c);
            if (info != null) {
              handlers.add(info);

              // Auto-collect type imports for handler class and referenced types
              final classUri = ImportAliasRegistry.getLibraryUri(c);
              if (classUri != null &&
                  classUri.scheme != 'dart' &&
                  !classUri.toString().startsWith('package:cqrs/')) {
                typeUris.add(classUri);
              }
              ImportAliasRegistry.collectTypeImports(
                info.messageType,
                typeUris,
              );
              ImportAliasRegistry.collectTypeImports(
                info.resultType,
                typeUris,
              );
            }
          }
        }
      } catch (_) {}
    }

    return ModuleScanResult(
      handlers: handlers,
      typeUris: typeUris,
      subModules: discoveredSubModules,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
