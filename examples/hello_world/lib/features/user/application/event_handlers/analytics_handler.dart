import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:hello_world/features/user/infrastructure/side_effect_log.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AnalyticsHandler implements EventHandler<UserCreatedEvent> {
  AnalyticsHandler(this._log);

  final SideEffectLog _log;

  @override
  Future<void> handle(UserCreatedEvent event) async {
    print('📊 Tracking analytics for new user ${event.userId}');
    _log.record('analytics:${event.userId}');
  }
}
