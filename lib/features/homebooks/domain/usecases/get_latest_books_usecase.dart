import '../entities/book_entity.dart';
import '../repositories/home_book_repository.dart';

class GetLatestBooksUseCase {
  final HomeRepository repository;

  GetLatestBooksUseCase(this.repository);

  Future<List<BookEntity>> call() async {
    return await repository.getLatestBooks();
  }
}
