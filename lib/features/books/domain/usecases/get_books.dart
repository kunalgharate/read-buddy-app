// features/books/domain/usecases/get_books.dart
import 'package:injectable/injectable.dart';

import 'package:read_buddy_app/features/books/domain/entities/book.dart';
import 'package:read_buddy_app/features/books/domain/repositories/book_repository.dart';

@injectable
class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<List<Book>> call() => repository.getBooks();
}
