import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
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
    required this.packageUri,
  });

  final String moduleClassName;
  final AssetId assetId;
  final String directory;
  final Uri packageUri;
}

/// Result of scanning a micro-package or root module directory.
class ModuleScanResult {
  const ModuleScanResult({
    required this.handlers,
    required this.typeUris,
    required this.subModules,
  });

  final List<HandlerInfo> handlers;
  final Set<Uri> typeUris;
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

  /// Extracts the library [Uri] from an [Element] or [LibraryElement].
  Uri? getLibraryUri(Element? element) {
    if (element == null) return null;
    try {
      final lib = element is LibraryElement ? element : element.library;
      if (lib != null) {
        final identifier = lib.identifier;
        if (identifier.isNotEmpty) {
          return Uri.tryParse(identifier);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Converts an [AssetId] into its absolute package URI string.
  Uri assetToPackageUri(AssetId assetId) {
    final path = assetId.path.startsWith('lib/')
        ? assetId.path.substring(4)
        : assetId.path;
    return Uri.parse('package:${assetId.package}/$path');
  }

  /// Formats a [DartType] with its aliased import prefix (e.g. `_i2.PlaceOrderCommand`).
  String formatTypeWithAlias(DartType? type, Map<Uri, String> importAliases) {
    if (type == null || type is DynamicType) return 'dynamic';
    if (type is VoidType) return 'void';
    if (type is NeverType) return 'Never';

    final element = type.element;
    final isNullable =
        type.nullabilitySuffix == NullabilitySuffix.question;
    final nullability = isNullable ? '?' : '';

    if (element != null) {
      final uri = getLibraryUri(element);
      final rawName = element.name ?? type.getDisplayString().replaceAll('?', '');
      final alias = uri != null ? importAliases[uri] : null;
      final prefix = (alias != null && uri?.scheme != 'dart') ? '$alias.' : '';

      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final typeArgs = type.typeArguments
            .map((arg) => formatTypeWithAlias(arg, importAliases))
            .join(', ');
        return '$prefix$rawName<$typeArgs>$nullability';
      }
      return '$prefix$rawName$nullability';
    }

    return type.getDisplayString();
  }

  /// Collects all library URIs referenced by a [DartType] and its generic arguments.
  void collectTypeImports(DartType? type, Set<Uri> imports) {
    if (type == null ||
        type is DynamicType ||
        type is VoidType ||
        type is NeverType) {
      return;
    }

    final element = type.element;
    if (element != null) {
      final uri = getLibraryUri(element);
      if (uri != null && uri.scheme != 'dart') {
        if (!uri.toString().startsWith('package:cqrs/')) {
          imports.add(uri);
        }
      }
    }

    if (type is ParameterizedType) {
      for (final typeArg in type.typeArguments) {
        collectTypeImports(typeArg, imports);
      }
    }
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
        if (asset == targetAsset ||
            asset.path.endsWith('.cqrs.dart') ||
            asset.path.endsWith('.config.dart') ||
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
              packageUri: assetToPackageUri(asset),
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
      if (asset == targetAsset ||
          asset.path.endsWith('.cqrs.dart') ||
          asset.path.endsWith('.config.dart') ||
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

        for (final c in lib.classes) {
          final name = c.name;
          if (name != null && visitedClassNames.add(name)) {
            final info = parser.parseClass(c);
            if (info != null) {
              handlers.add(info);

              // Auto-collect type imports for handler class and referenced types
              final classUri = getLibraryUri(c);
              if (classUri != null &&
                  classUri.scheme != 'dart' &&
                  !classUri.toString().startsWith('package:cqrs/')) {
                typeUris.add(classUri);
              }
              collectTypeImports(info.messageType, typeUris);
              collectTypeImports(info.resultType, typeUris);
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
