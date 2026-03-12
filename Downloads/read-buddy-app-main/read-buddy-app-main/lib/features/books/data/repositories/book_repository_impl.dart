// features/books/data/repositories/book_repository_impl.dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';

@Injectable(as: BookRepository)
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Book>> getBooks() async {
    return await remoteDataSource.getBooks();
  }
}
