import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class DeleteReview {
  final ReviewRepository repository;

  DeleteReview(this.repository);

  Future<void> call(String id) => repository.deleteReview(id);
}
