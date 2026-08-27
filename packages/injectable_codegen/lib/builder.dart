import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator/injectable_generator.dart';

/// Builder factory for Injectable code generator.
Builder injectableBuilder(BuilderOptions options) {
  return LibraryBuilder(
    const InjectableGenerator(),
    generatedExtension: '.config.dart',
    header: '',
  );
}
