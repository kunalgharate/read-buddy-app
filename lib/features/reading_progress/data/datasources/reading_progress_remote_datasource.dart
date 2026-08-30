import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_constants.dart';
import '../models/reading_progress_model.dart';

abstract class ReadingProgressRemoteDataSource {
  Future<ReadingProgressModel> saveProgress(ReadingProgressModel progress);
  Future<ReadingProgressModel?> getProgress(String bookId);
  Future<List<ReadingProgressModel>> getRecent({int limit});
}

class ReadingProgressRemoteDataSourceImpl
    implements ReadingProgressRemoteDataSource {
  final Dio _dio;

  ReadingProgressRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ReadingProgressModel> saveProgress(
      ReadingProgressModel progress) async {
    final response = await _dio.put(
      ApiConstants.readingProgress,
      data: progress.toJson(),
    );
    final data = response.data;
    final map = (data is Map && data['data'] is Map)
        ? data['data'] as Map<String, dynamic>
        : progress.toJson();
    return ReadingProgressModel.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  Future<ReadingProgressModel?> getProgress(String bookId) async {
    final response = await _dio.get(
      ApiConstants.readingProgressByBook(bookId),
    );
    final data = response.data;
    if (data is Map && data['data'] is Map) {
      return ReadingProgressModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map));
    }
    return null;
  }

  @override
  Future<List<ReadingProgressModel>> getRecent({int limit = 10}) async {
    final response = await _dio.get(
      ApiConstants.recentReadingProgress,
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    final List list = (data is Map && data['data'] is List)
        ? data['data'] as List
        : (data is List ? data : const []);

    final results = <ReadingProgressModel>[];
    for (final e in list) {
      try {
        results
            .add(ReadingProgressModel.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        if (kDebugMode) {
          print('⚠️ Skipping malformed reading progress record: $err');
        }
      }
    }
    return results;
  }
}
