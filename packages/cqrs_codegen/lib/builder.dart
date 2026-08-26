import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/cqrs_generator.dart';

/// Builder definition for `build_runner`.
Builder cqrsBuilder(BuilderOptions options) {
  return LibraryBuilder(
    const CqrsGenerator(),
    generatedExtension: '.cqrs.dart',
    header: '// GENERATED CODE - DO NOT MODIFY BY HAND\n',
  );
}
