import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

/// Manages mapping library [Uri]s to conflict-free aliases (`_i1`, `_i2`, etc.)
/// and formatting [DartType]s with aliased prefixes.
class ImportAliasRegistry {
  ImportAliasRegistry() {
    _aliases[Uri.parse('package:injectable/injectable.dart')] = '_i1';
    _aliases[Uri.parse('package:get_it/get_it.dart')] = '_i2';
  }

  final Map<Uri, String> _aliases = {};
  var _nextIndex = 3;

  /// Returns the unmodifiable map of all registered URI-to-alias pairs.
  Map<Uri, String> get aliases => Map.unmodifiable(_aliases);

  /// Returns the alias for [uri] if registered.
  String? prefixFor(Uri uri) => _aliases[uri];

  /// Registers a library [Uri] if not already present.
  String registerUri(Uri uri) {
    return _aliases.putIfAbsent(uri, () => '_i${_nextIndex++}');
  }

  /// Extracts the library [Uri] from an [Element].
  static Uri? getLibraryUri(Element? element) {
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

  /// Recursively collects all library URIs referenced by a [DartType].
  static void collectTypeImports(DartType? type, Set<Uri> imports) {
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
        if (!uri.toString().startsWith('package:injectable/')) {
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

  /// Formats a [DartType] with its aliased import prefix (e.g. `_i3.OrderRepository`).
  String formatType(DartType? type) {
    if (type == null || type is DynamicType) return 'dynamic';
    if (type is VoidType) return 'void';
    if (type is NeverType) return 'Never';

    final element = type.element;
    final isNullable =
        type.nullabilitySuffix == NullabilitySuffix.question;
    final nullability = isNullable ? '?' : '';

    if (element != null) {
      final uri = getLibraryUri(element);
      final rawName =
          element.name ?? type.getDisplayString().replaceAll('?', '');
      final alias = uri != null ? _aliases[uri] : null;
      final prefix = (alias != null && uri?.scheme != 'dart') ? '$alias.' : '';

      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final typeArgs = type.typeArguments
            .map((arg) => formatType(arg))
            .join(', ');
        return '$prefix$rawName<$typeArgs>$nullability';
      }
      return '$prefix$rawName$nullability';
    }

    return type.getDisplayString();
  }

  /// Formats a type name with its aliased prefix given the [Uri].
  String formatTypeName(String typeName, Uri? uri) {
    if (uri == null || uri.scheme == 'dart') return typeName;
    final alias = _aliases[uri];
    if (alias != null) {
      if (typeName.contains('<') && typeName.endsWith('>')) {
        final openIdx = typeName.indexOf('<');
        final outer = typeName.substring(0, openIdx);
        final inner = typeName.substring(openIdx + 1, typeName.length - 1);
        return '$outer<$alias.$inner>';
      }
      return '$alias.$typeName';
    }
    return typeName;
  }
}
