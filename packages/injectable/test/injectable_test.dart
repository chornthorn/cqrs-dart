import 'package:injectable/injectable.dart' hide test;
import 'package:test/test.dart';

class ServiceA {
  final String name;
  ServiceA([this.name = 'ServiceA']);
}

class ServiceB {
  final ServiceA a;
  ServiceB(this.a);
}

class ParamService {
  final String id;
  final int count;
  ParamService(this.id, this.count);
}

class SampleMicroModule extends MicroPackageModule {
  @override
  void init(GetItHelper gh) {
    gh.factory<ServiceA>(() => ServiceA('FromMicroModule'));
  }
}

void main() {
  group('GetItHelper', () {
    late GetIt locator;

    setUp(() {
      locator = GetIt.asNewInstance();
    });

    test('registers and resolves factory', () {
      final gh = GetItHelper(locator);
      gh.factory<ServiceA>(() => ServiceA('Test'));

      final s1 = locator<ServiceA>();
      final s2 = locator<ServiceA>();

      expect(s1.name, 'Test');
      expect(identical(s1, s2), isFalse);
    });

    test('registers and resolves lazySingleton', () {
      final gh = GetItHelper(locator);
      gh.lazySingleton<ServiceA>(() => ServiceA('Singleton'));

      final s1 = locator<ServiceA>();
      final s2 = locator<ServiceA>();

      expect(s1.name, 'Singleton');
      expect(identical(s1, s2), isTrue);
    });

    test('registers and resolves eager singleton', () {
      final gh = GetItHelper(locator);
      final instance = ServiceA('Eager');
      gh.singleton<ServiceA>(instance);

      final s = locator<ServiceA>();
      expect(identical(s, instance), isTrue);
    });

    test('registers factoryWithParam', () {
      final gh = GetItHelper(locator);
      gh.factoryWithParam<ParamService, String, int>(
        (id, count) => ParamService(id, count),
      );

      final s = locator.get<ParamService>(param1: 'abc', param2: 42);
      expect(s.id, 'abc');
      expect(s.count, 42);
    });

    test('filters dependencies by environment', () {
      final devHelper = GetItHelper(locator, environment: 'dev');
      devHelper.factory<ServiceA>(
        () => ServiceA('DevService'),
        registerFor: {'dev'},
      );
      devHelper.factory<ServiceA>(
        () => ServiceA('ProdService'),
        registerFor: {'prod'},
      );

      final s = locator<ServiceA>();
      expect(s.name, 'DevService');
    });

    test('initializes MicroPackageModule', () {
      final gh = GetItHelper(locator);
      gh.initMicroPackage(SampleMicroModule());

      expect(locator.isRegistered<ServiceA>(), isTrue);
      expect(locator<ServiceA>().name, 'FromMicroModule');
    });
  });

  group('EnvironmentFilter', () {
    test('NoEnvOrContains matches empty or contained environment', () {
      final filter = NoEnvOrContains({'dev'});
      expect(filter.canRegister({}), isTrue);
      expect(filter.canRegister({'dev'}), isTrue);
      expect(filter.canRegister({'dev', 'test_env'}), isTrue);
      expect(filter.canRegister({'prod'}), isFalse);
    });

    test('NoEnvOrContainsAll matches all required environments', () {
      final filter = NoEnvOrContainsAll({'dev', 'debug'});
      expect(filter.canRegister({}), isTrue);
      expect(filter.canRegister({'dev', 'debug'}), isTrue);
      expect(filter.canRegister({'dev', 'debug', 'extra'}), isFalse);
    });
  });
}
