// features/books/domain/repositories/book_repository.dart

import '../entities/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
}
