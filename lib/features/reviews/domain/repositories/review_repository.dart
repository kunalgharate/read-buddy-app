import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<BookReviewsResponse> getBookReviews(String bookId);
  Future<ReviewEntity> createReview({
    required String bookId,
    required int rating,
    required String comment,
  });
  Future<ReviewEntity> updateReview({
    required String id,
    required int rating,
    required String comment,
  });
  Future<void> deleteReview(String id);
}

class BookReviewsResponse {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;

  const BookReviewsResponse({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });
}
