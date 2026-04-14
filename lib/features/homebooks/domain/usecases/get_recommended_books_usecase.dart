import '../entities/book_entity.dart';
import '../repositories/home_book_repository.dart';

class GetRecommendedBookUseCase {
  final HomeRepository repository;

  GetRecommendedBookUseCase(this.repository);

  Future<List<BookEntity>> call() async {
    return await repository.getRecommendedBook();
  }
}
