import 'package:cqrs/cqrs.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:test/test.dart';

final getIt = GetIt.instance;

void main() {
  group('CqrsPackageModule', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('registers CqrsDispatcher into GetIt through module helper', () async {
      final module = CqrsPackageModule();
      final helper = GetItHelper(getIt);
      module.init(helper);

      expect(getIt.isRegistered<CqrsDispatcher>(), isTrue);
      final dispatcher = getIt<CqrsDispatcher>();
      expect(dispatcher, isA<CqrsDispatcher>());
    });
  });
}
