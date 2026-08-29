import 'package:cqrs/cqrs.dart';
import 'package:hello_world/features/notification/domain/entities/app_notification.dart';
import 'package:hello_world/features/notification/infrastructure/notification_repository.dart';
import 'package:injectable/injectable.dart';

class GetNotificationsQuery extends Query<List<AppNotification>> {
  GetNotificationsQuery(this.recipientId);

  final String recipientId;
}

@Injectable()
class GetNotificationsHandler
    implements QueryHandler<GetNotificationsQuery, List<AppNotification>> {
  GetNotificationsHandler(this._repository);

  final NotificationRepository _repository;

  @override
  Future<List<AppNotification>> execute(GetNotificationsQuery query) async {
    return _repository.findByRecipient(query.recipientId);
  }
}
