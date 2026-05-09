import 'package:read_buddy_app/features/homebooks/domain/entities/book_entity.dart';
import 'package:read_buddy_app/features/homebooks/domain/repositories/home_book_repository.dart';

class GetTrendingBooksUseCase {
  final HomeRepository repository;

  GetTrendingBooksUseCase(this.repository);

  Future<List<BookEntity>> call() async {
    return await repository.getTrendingBooks();
  }
}
