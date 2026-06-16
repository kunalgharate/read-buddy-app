import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendNotification({
    required String userId,
    required String message,
    required String type,
  });

  Future<List<Map<String, dynamic>>> getMyNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<void> sendNotification({
    required String userId,
    required String message,
    required String type,
  }) async {
    await _dio.post(
      '${ApiConstants.baseUrl}/notifications/send',
      data: {
        'userId': userId,
        'message': message,
        'type': type,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final response = await _dio.get(
      '${ApiConstants.baseUrl}/notifications/my',
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }
}
