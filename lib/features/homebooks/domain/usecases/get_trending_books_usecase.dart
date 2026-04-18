import '../entities/book_entity.dart';
import '../repositories/home_book_repository.dart';

class GetTrendingBooksUseCase {
  final HomeRepository repository;

  GetTrendingBooksUseCase(this.repository);

  Future<List<BookEntity>> call() async {
    return await repository.getTrendingBooks();
  }
}
