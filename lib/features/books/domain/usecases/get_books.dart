// features/books/domain/usecases/get_books.dart
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<List<Book>> call() => repository.getBooks();
}
