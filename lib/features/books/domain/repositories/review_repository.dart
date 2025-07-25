import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getReviews(String bookId);
  // Future<List<ReviewEntity>> getReviews();
}
