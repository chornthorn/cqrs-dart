import 'package:dart_cqrs/dart_cqrs.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:injectable/injectable.dart';

class GetUnreadNotificationCountQuery extends Query<int> {
  GetUnreadNotificationCountQuery(this.recipientId);

  final String recipientId;
}

@Injectable(as: QueryHandler<GetUnreadNotificationCountQuery, int>)
class GetUnreadNotificationCountHandler
    implements QueryHandler<GetUnreadNotificationCountQuery, int> {
  GetUnreadNotificationCountHandler(this._repository);

  final NotificationRepository _repository;

  @override
  Future<int> execute(GetUnreadNotificationCountQuery query) async {
    return _repository.countUnread(query.recipientId);
  }
}
