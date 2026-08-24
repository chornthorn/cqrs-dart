import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/user/domain/events/user_created_event.dart';
import 'package:hello_world/features/user/infrastructure/side_effect_log.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: EventHandler<UserCreatedEvent>)
class WelcomeEmailHandler implements EventHandler<UserCreatedEvent> {
  WelcomeEmailHandler(this._log);

  final SideEffectLog _log;

  @override
  Future<void> handle(UserCreatedEvent event) async {
    print('📨 Sending welcome email to ${event.userId}');
    _log.record('welcome:${event.userId}');
  }
}
