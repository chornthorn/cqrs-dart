import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import '../annotations/cqrs_annotations.dart';
import '../model/handler_info.dart';
import '../parser/handler_parser.dart';

/// Information about a discovered micro-package module boundary.
class DiscoveredModule {
  const DiscoveredModule({
    required this.moduleClassName,
    required this.assetId,
    required this.directory,
  });

  final String moduleClassName;
  final AssetId assetId;
  final String directory;
}

/// Result of scanning a micro-package or root module directory.
class ModuleScanResult {
  const ModuleScanResult({
    required this.handlers,
    required this.handlerImportUris,
    required this.subModules,
  });

  final List<HandlerInfo> handlers;
  final List<String> handlerImportUris;
  final List<DiscoveredModule> subModules;
}

/// Reusable boundary-aware directory scanner for code generators.
class LibraryScanner {
  const LibraryScanner({this.parser = const HandlerParser()});

  final HandlerParser parser;

  static const _anyChecker = TypeChecker.any([
    TypeChecker.typeNamed(CqrsInit),
    TypeChecker.typeNamed(CqrsMicroPackage),
  ]);

  /// Extracts the module class name from an annotated [LibraryElement] or AST.
  String? findMicroPackageModuleClass(LibraryElement lib) {
    // 1. Try via source_gen TypeChecker
    try {
      final reader = LibraryReader(lib);
      final annotated = reader.annotatedWith(_anyChecker);
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

  /// Scans the directory of [targetAsset] using [buildStep], respecting nested
  /// `@CqrsMicroPackage` boundaries.
  Future<ModuleScanResult> scanDirectory({
    required BuildStep buildStep,
    required AssetId targetAsset,
    required bool isRootCompositor,
  }) async {
    final targetDirPath = p.dirname(targetAsset.path);
    final searchGlob = isRootCompositor
        ? Glob('lib/**.dart')
        : Glob('$targetDirPath/**.dart');

    final allAssets = await buildStep.findAssets(searchGlob).toList();
    final excludedDirs = <String>{};
    final discoveredSubModules = <DiscoveredModule>[];

    // 1. Discover all micro-package boundaries
    for (final asset in allAssets) {
      if (asset == targetAsset ||
          asset.path.endsWith('.cqrs.dart') ||
          asset.path.endsWith('.g.dart')) {
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
          );
          discoveredSubModules.add(module);

          // If this is not the root compositor and not the current target asset,
          // exclude its subtree from the parent module's handler scanning.
          if (!isRootCompositor && assetDir != targetDirPath) {
            excludedDirs.add(assetDir);
          }
        }
      } catch (_) {}
    }

    if (isRootCompositor) {
      return ModuleScanResult(
        handlers: const [],
        handlerImportUris: const [],
        subModules: discoveredSubModules,
      );
    }

    discoveredSubModules.clear();

    // 2. Scan handlers only in files belonging to this module's boundary
    final handlers = <HandlerInfo>[];
    final handlerImportUris = <String>{};
    final visitedClassNames = <String>{};

    for (final asset in allAssets) {
      if (asset == targetAsset ||
          asset.path.endsWith('.cqrs.dart') ||
          asset.path.endsWith('.g.dart')) {
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
        bool hasHandlersInThisFile = false;

        for (final c in lib.classes) {
          final name = c.name;
          if (name != null && visitedClassNames.add(name)) {
            final info = parser.parseClass(c);
            if (info != null) {
              handlers.add(info);
              hasHandlersInThisFile = true;
            }
          }
        }

        if (hasHandlersInThisFile) {
          // Derive a relative import path from target asset directory to this asset
          final relativeImport = p
              .relative(asset.path, from: targetDirPath)
              .replaceAll(r'\', '/');
          handlerImportUris.add(relativeImport);
        }
      } catch (_) {}
    }

    return ModuleScanResult(
      handlers: handlers,
      handlerImportUris: handlerImportUris.toList()..sort(),
      subModules: discoveredSubModules,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
