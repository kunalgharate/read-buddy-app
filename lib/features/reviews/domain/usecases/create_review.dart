import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class CreateReview {
  final ReviewRepository repository;

  CreateReview(this.repository);

  Future<ReviewEntity> call({
    required String bookId,
    required int rating,
    required String comment,
  }) =>
      repository.createReview(
        bookId: bookId,
        rating: rating,
        comment: comment,
      );
}
