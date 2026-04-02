import '../repositories/donated_books_repository.dart';
import '../entities/donated_books_entity.dart';

class GetDonatedBooksByCategory {
  final DonatedBooksRepository repository;

  GetDonatedBooksByCategory(this.repository);

  Future<List<DonatedBooksEntity>> call(String category) async {
    final books = await repository.getDonatedBooks();
    if (category.isEmpty || category == 'All') {
      return books;
    }
    List<DonatedBooksEntity> filteredBooks = [];

    for (var book in books) {
      if (book.category == category) {
        filteredBooks.add(book);
      }
    }
    return filteredBooks;
  }
}
