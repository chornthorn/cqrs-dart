/// Code generator for injectable annotations with micro-package boundary scanning.
library;

export 'package:injectable/injectable.dart';

export 'src/generator/injectable_generator.dart';
export 'src/model/dependency_info.dart';
export 'src/model/import_alias_registry.dart';
export 'src/model/module_info.dart';
export 'src/parser/annotation_parser.dart';
export 'src/parser/dependency_parser.dart';
export 'src/scanner/library_scanner.dart';
