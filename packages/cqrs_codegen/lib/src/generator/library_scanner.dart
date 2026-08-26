import 'package:analyzer/dart/element/element.dart';

/// A reusable utility that traverses a Dart [LibraryElement] and its exported libraries,
/// with support for boundary detection (such as micro-package / sub-module annotations).
///
/// This visitor pattern can be reused across different code generators (CQRS, DI, Routing, etc.)
/// that need hierarchical module composition.
class LibraryScanner {
  const LibraryScanner();

  /// Scans [rootLibrary] and its exported libraries.
  ///
  /// - [onClass]: Invoked for each unique [ClassElement] found in scanned libraries.
  /// - [findBoundary]: Optional callback that checks whether a [LibraryElement] represents
  ///   a sub-module / micro-package boundary and returns an identifier (e.g., class name).
  /// - [onBoundaryDiscovered]: Invoked when a boundary is detected.
  /// - [isRootCompositor]: If `true`, traverses the entire export tree transitively to discover
  ///   all sub-module boundaries across all nesting levels (and skips class inspection).
  ///   If `false`, stops descending into a branch when a boundary is met and inspects classes.
  void scan({
    required LibraryElement rootLibrary,
    required void Function(ClassElement classElement) onClass,
    String? Function(LibraryElement library)? findBoundary,
    void Function(String boundaryName)? onBoundaryDiscovered,
    bool isRootCompositor = false,
  }) {
    final visitedLibraries = <LibraryElement>{};
    final visitedClassNames = <String>{};

    void visit(LibraryElement lib, {required bool isRoot}) {
      if (lib.isInSdk || !visitedLibraries.add(lib)) return;

      if (!isRoot && findBoundary != null) {
        final boundaryName = findBoundary(lib);
        if (boundaryName != null) {
          onBoundaryDiscovered?.call(boundaryName);
          if (!isRootCompositor) {
            // Stop scanning deeper at this boundary for independent/leaf modules
            return;
          }
        }
      }

      // Inspect classes in non-boundary or non-root-compositor libraries
      if (!isRootCompositor) {
        for (final c in lib.classes) {
          final name = c.name;
          if (name != null && visitedClassNames.add(name)) {
            onClass(c);
          }
        }
      }

      // Recursively scan exported libraries
      for (final exported in lib.exportedLibraries) {
        visit(exported, isRoot: false);
      }
    }

    visit(rootLibrary, isRoot: true);
  }
}
