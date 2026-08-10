import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/reviews/data/models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<Map<String, dynamic>> getBookReviews(String bookId);
  Future<ReviewModel> createReview({
    required String bookId,
    required int rating,
    required String comment,
  });
  Future<ReviewModel> updateReview({
    required String id,
    required int rating,
    required String comment,
  });
  Future<void> deleteReview(String id);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getBookReviews(String bookId) async {
    final response = await dio.get(ApiConstants.reviewsByBook(bookId));

    if (response.statusCode != ApiConstants.success) {
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final reviewsList = data['reviews'] ?? [];
      final reviews = (reviewsList as List)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return {
        'reviews': reviews,
        'averageRating': (data['averageRating'] is num)
            ? (data['averageRating'] as num).toDouble()
            : 0.0,
        'totalReviews': (data['totalReviews'] is num)
            ? (data['totalReviews'] as num).toInt()
            : reviews.length,
      };
    }

    throw Exception('Unexpected response format');
  }

  @override
  Future<ReviewModel> createReview({
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    final response = await dio.post(
      ApiConstants.reviews,
      data: {
        'bookId': bookId,
        'rating': rating,
        'comment': comment,
      },
    );

    if (response.statusCode != ApiConstants.success &&
        response.statusCode != ApiConstants.created) {
      throw Exception('Failed to create review: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Response might have review nested under 'review' key or at root
      final reviewData = data.containsKey('review')
          ? data['review'] as Map<String, dynamic>
          : data;
      return ReviewModel.fromJson(reviewData);
    }

    throw Exception('Unexpected response format');
  }

  @override
  Future<ReviewModel> updateReview({
    required String id,
    required int rating,
    required String comment,
  }) async {
    final response = await dio.put(
      ApiConstants.reviewById(id),
      data: {
        'rating': rating,
        'comment': comment,
      },
    );

    if (response.statusCode != ApiConstants.success) {
      throw Exception('Failed to update review: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final reviewData = data.containsKey('review')
          ? data['review'] as Map<String, dynamic>
          : data;
      return ReviewModel.fromJson(reviewData);
    }

    throw Exception('Unexpected response format');
  }

  @override
  Future<void> deleteReview(String id) async {
    final response = await dio.delete(ApiConstants.reviewById(id));

    if (response.statusCode != ApiConstants.success) {
      throw Exception('Failed to delete review: ${response.statusCode}');
    }
  }
}
