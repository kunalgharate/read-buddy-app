import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

import 'package:read_buddy_app/features/donated_books/domain/repositories/donated_books_repository.dart';
import 'package:read_buddy_app/features/donated_books/data/datasources/donation_remote_data_source.dart';

class DonatedBooksRepositoryImpl implements DonatedBooksRepository {
  final DonatedBooksRemoteDataSource remoteDataSource;

  DonatedBooksRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DonatedBooksEntity>> getDonatedBooks() async {
    return await remoteDataSource.getDonatedBooks();
  }
}
