import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase({required this.repository});

  Future<List<ReviewEntity>> call(String bookId) async {
    return await repository.getReviews(bookId);
  }
}
