import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<void> sendNotification({
    required String userId,
    required String message,
    required String type,
  }) {
    return _dataSource.sendNotification(
      userId: userId,
      message: message,
      type: type,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMyNotifications() {
    return _dataSource.getMyNotifications();
  }
}
