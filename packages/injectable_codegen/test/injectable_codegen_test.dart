import 'package:injectable_codegen/src/model/dependency_info.dart';
import 'package:injectable_codegen/src/model/import_alias_registry.dart';
import 'package:test/test.dart';

void main() {
  group('ImportAliasRegistry', () {
    late ImportAliasRegistry registry;

    setUp(() {
      registry = ImportAliasRegistry();
    });

    test('assigns deterministic import prefixes', () {
      final uri1 = Uri.parse('package:hello_world/services/user_service.dart');
      final uri2 = Uri.parse('package:hello_world/services/auth_service.dart');

      final prefix1 = registry.registerUri(uri1);
      final prefix2 = registry.registerUri(uri2);

      expect(prefix1, isNotNull);
      expect(prefix2, isNotNull);
      expect(prefix1, isNot(equals(prefix2)));
      expect(registry.prefixFor(uri1), equals(prefix1));
    });

    test('formats type names with registered prefixes', () {
      final uri = Uri.parse('package:hello_world/models/user.dart');
      registry.registerUri(uri);

      final formatted = registry.formatTypeName('User', uri);
      final prefix = registry.prefixFor(uri);
      expect(formatted, equals('$prefix.User'));
    });

    test('handles generic types in formatTypeName', () {
      final uri = Uri.parse('package:hello_world/models/user.dart');
      registry.registerUri(uri);

      final formatted = registry.formatTypeName('List<User>', uri);
      final prefix = registry.prefixFor(uri);
      expect(formatted, equals('List<$prefix.User>'));
    });
  });

  group('DependencyInfo', () {
    test('separates factoryParams and injectedParams correctly', () {
      const dep = DependencyInfo(
        className: 'TestService',
        boundType: 'TestService',
        kind: DependencyKind.factory,
        params: [
          InjectedParam(name: 'id', typeName: 'String', isFactoryParam: true),
          InjectedParam(
              name: 'repo', typeName: 'Repository', isFactoryParam: false),
        ],
      );

      expect(dep.factoryParams.length, 1);
      expect(dep.factoryParams.first.name, 'id');
      expect(dep.injectedParams.length, 1);
      expect(dep.injectedParams.first.name, 'repo');
    });
  });
}
