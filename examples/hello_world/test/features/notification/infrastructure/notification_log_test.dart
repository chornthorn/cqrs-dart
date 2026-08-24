import 'package:hello_world/features/notification/infrastructure/notification_log.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationLog', () {
    test('records entries properly', () {
      final log = NotificationLog();
      expect(log.entries, isEmpty);

      log.record('entry:1');
      log.record('entry:2');

      expect(log.entries, ['entry:1', 'entry:2']);
    });
  });
}
