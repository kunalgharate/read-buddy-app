import 'package:dio/dio.dart';

import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> fetchReviews(String bookId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReviewModel>> fetchReviews(String bookId) async {
    try {
      final response = await dio.get(
        'https://readbuddy-server.onrender.com/api/review?bookId=$bookId',
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;

        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch reviews');
      }
    } catch (e) {
      throw Exception('Review fetch error: $e');
    }
  }
}
