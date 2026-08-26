import '../model/import_alias_registry.dart';

/// Emits the top-of-file linter ignore header and aliased import statements.
class ImportEmitter {
  const ImportEmitter();

  /// Writes file header and aliased import statements to [buffer].
  void writeImports(StringBuffer buffer, ImportAliasRegistry aliasRegistry) {
    buffer.writeln(
      '// ignore_for_file: no_leading_underscores_for_library_prefixes, prefer_initializing_formals',
    );
    buffer.writeln();

    for (final entry in aliasRegistry.aliases.entries) {
      buffer.writeln("import '${entry.key}' as ${entry.value};");
    }
    buffer.writeln();
  }
}
