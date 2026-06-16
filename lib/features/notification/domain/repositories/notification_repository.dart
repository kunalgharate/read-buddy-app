abstract class NotificationRepository {
  Future<void> sendNotification({
    required String userId,
    required String message,
    required String type,
  });

  Future<List<Map<String, dynamic>>> getMyNotifications();
}
