import 'package:dart_cqrs/dart_cqrs.dart';

class UserCreatedEvent extends DomainEvent {
  UserCreatedEvent(this.userId);

  final String userId;
}
