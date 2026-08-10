import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';

class GetBookReviews {
  final ReviewRepository repository;

  GetBookReviews(this.repository);

  Future<BookReviewsResponse> call(String bookId) =>
      repository.getBookReviews(bookId);
}
