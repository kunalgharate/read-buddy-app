import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class UpdateReview {
  final ReviewRepository repository;

  UpdateReview(this.repository);

  Future<ReviewEntity> call({
    required String id,
    required int rating,
    required String comment,
  }) =>
      repository.updateReview(
        id: id,
        rating: rating,
        comment: comment,
      );
}
