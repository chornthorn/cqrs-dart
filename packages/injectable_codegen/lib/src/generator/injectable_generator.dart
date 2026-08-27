import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../emitter/import_emitter.dart';
import '../emitter/module_class_emitter.dart';
import '../emitter/registration_emitter.dart';
import '../model/import_alias_registry.dart';
import '../parser/annotation_parser.dart';
import '../scanner/library_scanner.dart';

/// Source generator coordinating dependency scanning, nested micro-package resolution,
/// and GetIt initialization code generation.
class InjectableGenerator extends Generator {
  const InjectableGenerator({
    this.annotationParser = const AnnotationParser(),
    this.scanner = const LibraryScanner(),
    this.importEmitter = const ImportEmitter(),
    this.registrationEmitter = const RegistrationEmitter(),
    this.moduleClassEmitter = const ModuleClassEmitter(),
  });

  final AnnotationParser annotationParser;
  final LibraryScanner scanner;
  final ImportEmitter importEmitter;
  final RegistrationEmitter registrationEmitter;
  final ModuleClassEmitter moduleClassEmitter;

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    // 1. Parse configuration from annotation
    final config = annotationParser.parse(library);
    if (config == null) return null;

    // 2. Check if micro-packages are globally disabled
    if (config.isMicroPackage) {
      final isGloballyEnabled =
          await scanner.isMicroPackageGloballyEnabled(buildStep);
      if (!isGloballyEnabled) {
        return null;
      }
    }

    final bool isRootCompositor =
        !config.isMicroPackage && config.useMicroPackage;

    // 3. Scan directory for dependencies and sub-modules
    final scanResult = await scanner.scanDirectory(
      buildStep: buildStep,
      targetAsset: buildStep.inputId,
      isMicroPackage: config.isMicroPackage,
      useMicroPackage: config.useMicroPackage,
    );

    final dependencies = scanResult.dependencies;
    final discoveredModuleClasses = <String>[
      for (final sub in scanResult.subModules) sub.moduleClassName,
    ];

    final effectiveModuleClasses = config.manualModuleTypeNames.isNotEmpty
        ? config.manualModuleTypeNames
        : discoveredModuleClasses;

    final effectiveSubModules = scanResult.subModules
        .where((s) => effectiveModuleClasses.contains(s.moduleClassName))
        .toList();

    // 4. Build import aliases registry
    final aliasRegistry = ImportAliasRegistry();

    if (isRootCompositor) {
      for (final sub in effectiveSubModules) {
        aliasRegistry.registerUri(sub.packageUri);
      }
      for (final uri in scanResult.typeUris) {
        aliasRegistry.registerUri(uri);
      }
    } else {
      for (final uri in scanResult.typeUris) {
        aliasRegistry.registerUri(uri);
      }
    }

    final buffer = StringBuffer();

    // 5. Emit imports
    importEmitter.writeImports(buffer, aliasRegistry);

    // 6. If micro-package, emit MicroPackageModule class
    if (config.isMicroPackage) {
      moduleClassEmitter.writeMicroPackageModule(
        buffer,
        moduleClassName: config.moduleClassName,
        dependencies: dependencies,
        subModules: effectiveSubModules,
        aliasRegistry: aliasRegistry,
      );
      buffer.writeln();
    }

    // 7. Emit GetIt initialization extension
    if (config.asExtension) {
      moduleClassEmitter.writeGetItExtension(
        buffer,
        initializerName: config.initializerName,
        moduleClassName:
            config.isMicroPackage ? config.moduleClassName : null,
        isMicroPackage: config.isMicroPackage,
        useMicroPackage: config.useMicroPackage,
        dependencies: dependencies,
        subModules: effectiveSubModules,
        aliasRegistry: aliasRegistry,
      );
    }

    // 8. Emit abstract module class implementations if needed
    registrationEmitter.writeAbstractModuleClasses(
      buffer,
      dependencies: dependencies,
      aliasRegistry: aliasRegistry,
    );

    return buffer.toString();
  }
}
