// features/books/data/repositories/book_repository_impl.dart
import 'package:injectable/injectable.dart';

import 'package:read_buddy_app/features/books/domain/entities/book.dart';
import 'package:read_buddy_app/features/books/domain/repositories/book_repository.dart';
import 'package:read_buddy_app/features/books/data/datasources/book_remote_data_source.dart';

@Injectable(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Book>> getBooks() async {
    return await remoteDataSource.getBooks();
  }
}
