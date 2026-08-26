import 'package:build/build.dart';

import 'handler_info.dart';

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

/// Parsed configuration options from `@CqrsInit` or `@CqrsMicroPackage`.
class CqrsGeneratorConfig {
  const CqrsGeneratorConfig({
    required this.isMicroPackage,
    required this.useMicroPackage,
    required this.generateInjectable,
    required this.includeDefaults,
    required this.extensionName,
    required this.methodName,
    required this.moduleClassName,
    required this.manualModuleTypeNames,
  });

  final bool isMicroPackage;
  final bool useMicroPackage;
  final bool generateInjectable;
  final bool includeDefaults;
  final String extensionName;
  final String methodName;
  final String moduleClassName;
  final List<String> manualModuleTypeNames;
}
