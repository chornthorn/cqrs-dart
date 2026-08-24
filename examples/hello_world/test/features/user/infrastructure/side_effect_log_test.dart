import 'package:hello_world/features/user/infrastructure/side_effect_log.dart';
import 'package:test/test.dart';

void main() {
  group('SideEffectLog', () {
    test('records entries properly', () {
      final log = SideEffectLog();
      expect(log.entries, isEmpty);

      log.record('event:1');
      log.record('event:2');

      expect(log.entries, ['event:1', 'event:2']);
    });
  });
}
