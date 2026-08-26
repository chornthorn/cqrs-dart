import 'package:cqrs/cqrs.dart';

class UserCreatedEvent extends Event {
  UserCreatedEvent(this.userId);

  final String userId;
}
