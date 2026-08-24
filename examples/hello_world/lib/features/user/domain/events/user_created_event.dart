import 'package:cqrs/cqrs.dart';

class UserCreatedEvent extends DomainEvent {
  UserCreatedEvent(this.userId);

  final String userId;
}
