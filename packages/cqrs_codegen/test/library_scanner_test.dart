import 'package:cqrs_codegen/cqrs_codegen.dart';
import 'package:test/test.dart';

void main() {
  group('LibraryScanner', () {
    test('can be instantiated with const constructor', () {
      const scanner = LibraryScanner();
      expect(scanner, isNotNull);
    });
  });
}
