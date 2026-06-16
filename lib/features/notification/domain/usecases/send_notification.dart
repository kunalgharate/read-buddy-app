import '../repositories/notification_repository.dart';

class SendNotificationUsecase {
  final NotificationRepository _repository;

  SendNotificationUsecase(this._repository);

  Future<void> call({
    required String userId,
    required String message,
    required String type,
  }) {
    return _repository.sendNotification(
      userId: userId,
      message: message,
      type: type,
    );
  }
}
