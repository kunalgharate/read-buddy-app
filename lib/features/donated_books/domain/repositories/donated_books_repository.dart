import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

abstract class DonatedBooksRepository {
  Future<List<DonatedBooksEntity>> getDonatedBooks();
}
