import 'package:hello_world/features/user/application/event_handlers/analytics_handler.dart';
import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:hello_world/features/user/infrastructure/side_effect_log.dart';
import 'package:test/test.dart';

void main() {
  group('AnalyticsHandler', () {
    test('records analytics event into log', () async {
      final log = SideEffectLog();
      final handler = AnalyticsHandler(log);

      await handler.handle(UserCreatedEvent('USER-123'));

      expect(log.entries, ['analytics:USER-123']);
    });
  });
}
