import 'package:read_buddy_app/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:read_buddy_app/features/reviews/data/models/review_model.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<BookReviewsResponse> getBookReviews(String bookId) async {
    final result = await remoteDataSource.getBookReviews(bookId);
    return BookReviewsResponse(
      reviews: result['reviews'] as List<ReviewModel>,
      averageRating: result['averageRating'] as double,
      totalReviews: result['totalReviews'] as int,
    );
  }

  @override
  Future<ReviewEligibilityEntity> getEligibility(String bookId) async {
    return await remoteDataSource.getEligibility(bookId);
  }

  @override
  Future<ReviewEntity> createReview({
    required String bookId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    return await remoteDataSource.createReview(
      bookId: bookId,
      rating: rating,
      title: title,
      comment: comment,
    );
  }

  @override
  Future<ReviewEntity> updateReview({
    required String id,
    required int rating,
    required String title,
    required String comment,
  }) async {
    return await remoteDataSource.updateReview(
      id: id,
      rating: rating,
      title: title,
      comment: comment,
    );
  }

  @override
  Future<void> deleteReview(String id) async {
    await remoteDataSource.deleteReview(id);
  }
}
