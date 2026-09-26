import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class GetReviewEligibility {
  final ReviewRepository repository;

  GetReviewEligibility(this.repository);

  Future<ReviewEligibilityEntity> call(String bookId) =>
      repository.getEligibility(bookId);
}
