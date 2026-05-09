import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/monthly_stats/data/models/monthly_stat_model.dart';

/// Abstract data source interface
abstract class MonthlyStatsRemoteDataSource {
  Future<List<MonthlyStatModel>> getMonthlyStats();
}

/// Implementation of remote data source using Dio
class MonthlyStatsRemoteDataSourceImpl implements MonthlyStatsRemoteDataSource {
  final Dio dio;

  MonthlyStatsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MonthlyStatModel>> getMonthlyStats() async {
    try {
      // Make GET request to API
      final response = await dio.get(ApiConstants.monthlyData);

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle different response structures
        if (data is Map<String, dynamic>) {
          // If response has a 'data' field containing the list
          if (data.containsKey('data')) {
            final List<dynamic> statsJson = data['data'] as List<dynamic>;
            return statsJson
                .map((json) =>
                    MonthlyStatModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          // If response has a 'stats' field
          else if (data.containsKey('stats')) {
            final List<dynamic> statsJson = data['stats'] as List<dynamic>;
            return statsJson
                .map((json) =>
                    MonthlyStatModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
        // If response is directly a list
        else if (data is List) {
          return data
              .map((json) =>
                  MonthlyStatModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to load monthly stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - server may be starting up');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout - slow server response');
      } else if (e.response != null) {
        throw Exception(
          'API Error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch monthly stats: $e');
    }
  }
}
