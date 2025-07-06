// lib/features/book/domain/repositories/book_repository.dart

import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

abstract class BookCrudRepository {
  /// Get all books
  Future<List<BookCrudEntity>> getBooks();

  /// Get a single book by ID
  Future<BookCrudEntity> getBookById(String id);

  /// Add a new book
  Future<void> addBook(BookCrudEntity book);

  /// Update an existing book
  Future<void> updateBook(String id, BookCrudEntity book);

  /// Delete a book
  Future<void> deleteBook(String id);
}
