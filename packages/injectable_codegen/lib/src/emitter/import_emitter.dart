import '../model/import_alias_registry.dart';

/// Emits aliased import directives for generated code.
class ImportEmitter {
  const ImportEmitter();

  /// Writes all registered imports to [buffer].
  void writeImports(StringBuffer buffer, ImportAliasRegistry aliasRegistry) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('// **************************************************************************');
    buffer.writeln('// InjectableConfigGenerator');
    buffer.writeln('// **************************************************************************');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln('// coverage:ignore-file');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: no_leading_underscores_for_library_prefixes');

    // Emit package/relative imports with aliases
    for (final entry in aliasRegistry.aliases.entries) {
      final uri = entry.key;
      final alias = entry.value;
      buffer.writeln("import '$uri' as $alias;");
    }

    buffer.writeln();
  }
}
