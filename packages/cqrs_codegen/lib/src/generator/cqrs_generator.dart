import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../emitter/extension_emitter.dart';
import '../emitter/import_emitter.dart';
import '../emitter/module_class_emitter.dart';
import '../model/import_alias_registry.dart';
import '../model/module_info.dart';
import '../parser/annotation_parser.dart';
import '../scanner/library_scanner.dart';

/// Source generator that coordinates parsing, scanning, and emitting
/// CQRS handler registrations and micro-package module classes.
class CqrsGenerator extends Generator {
  const CqrsGenerator({
    this.annotationParser = const AnnotationParser(),
    this.scanner = const LibraryScanner(),
    this.importEmitter = const ImportEmitter(),
    this.extensionEmitter = const ExtensionEmitter(),
    this.moduleClassEmitter = const ModuleClassEmitter(),
  });

  final AnnotationParser annotationParser;
  final LibraryScanner scanner;
  final ImportEmitter importEmitter;
  final ExtensionEmitter extensionEmitter;
  final ModuleClassEmitter moduleClassEmitter;

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    // 1. Parse configuration from annotation
    var config = annotationParser.parse(library);
    if (config == null) return null;

    // 2. Check if micro-packages are globally disabled or if injectable is globally enabled
    if (config.isMicroPackage) {
      final isGloballyEnabled =
          await scanner.isMicroPackageGloballyEnabled(buildStep);
      if (!isGloballyEnabled) {
        return null;
      }
    }

    if (!config.generateInjectable) {
      final isInjectableEnabled =
          await scanner.isInjectableGloballyEnabled(buildStep);
      if (isInjectableEnabled) {
        config = config.copyWith(generateInjectable: true);
      }
    }

    final bool isRootCompositor =
        !config.isMicroPackage && config.useMicroPackage;

    // 3. Scan directory for handlers and sub-modules
    final scanResult = await scanner.scanDirectory(
      buildStep: buildStep,
      targetAsset: buildStep.inputId,
      isMicroPackage: config.isMicroPackage,
      useMicroPackage: config.useMicroPackage,
    );

    final handlers = scanResult.handlers;
    final discoveredModuleClasses = <String>[
      for (final sub in scanResult.subModules) sub.moduleClassName,
    ];

    // Prioritize manual module list if provided
    final effectiveModuleClasses = config.manualModuleTypeNames.isNotEmpty
        ? config.manualModuleTypeNames
        : discoveredModuleClasses;

    final bool shouldEmitModuleClass = config.useMicroPackage &&
        (handlers.isNotEmpty || effectiveModuleClasses.isNotEmpty);

    // 4. Build import aliases registry
    final aliasRegistry = ImportAliasRegistry();
    if (isRootCompositor) {
      for (final sub in scanResult.subModules) {
        if (effectiveModuleClasses.contains(sub.moduleClassName)) {
          aliasRegistry.registerUri(sub.packageUri);
        }
      }
    } else {
      for (final uri in scanResult.typeUris) {
        aliasRegistry.registerUri(uri);
      }
    }

    final buffer = StringBuffer();

    // 5. Emit imports
    importEmitter.writeImports(buffer, aliasRegistry);

    // 6. Emit HandlerRegistry extension (only when direct handlers exist or no module class is emitted)
    if (handlers.isNotEmpty || !shouldEmitModuleClass) {
      extensionEmitter.writeExtension(
        buffer,
        extensionName: config.extensionName,
        methodName: config.methodName,
        handlers: handlers,
        includeDefaults: config.includeDefaults,
        generateInjectable: config.generateInjectable,
        aliasRegistry: aliasRegistry,
      );
    }

    // 7. Emit CqrsPackageModule subclass
    if (shouldEmitModuleClass) {
      buffer.writeln();
      moduleClassEmitter.writeModuleClass(
        buffer,
        moduleClassName: config.moduleClassName,
        methodName: config.methodName,
        handlers: handlers,
        subModules: scanResult.subModules
            .where((s) => effectiveModuleClasses.contains(s.moduleClassName))
            .toList(),
        includeDefaults: config.includeDefaults,
        generateInjectable: config.generateInjectable,
        aliasRegistry: aliasRegistry,
      );
    }

    return buffer.toString();
  }
}

extension on CqrsGeneratorConfig {
  CqrsGeneratorConfig copyWith({bool? generateInjectable}) {
    return CqrsGeneratorConfig(
      isMicroPackage: isMicroPackage,
      useMicroPackage: useMicroPackage,
      generateInjectable: generateInjectable ?? this.generateInjectable,
      includeDefaults: includeDefaults,
      extensionName: extensionName,
      methodName: methodName,
      moduleClassName: moduleClassName,
      manualModuleTypeNames: manualModuleTypeNames,
    );
  }
}
