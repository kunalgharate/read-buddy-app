// features/books/domain/repositories/book_repository.dart

import 'package:read_buddy_app/features/books/domain/entities/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
}
