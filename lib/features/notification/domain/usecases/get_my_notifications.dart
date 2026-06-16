import '../repositories/notification_repository.dart';

class GetMyNotificationsUsecase {
  final NotificationRepository _repository;

  GetMyNotificationsUsecase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getMyNotifications();
  }
}
