import '../repositories/donated_books_repository.dart';
import '../entities/donated_books_entity.dart';

class FilterDonatedBooks {
  final DonatedBooksRepository repository;

  FilterDonatedBooks(this.repository);

  Future<List<DonatedBooksEntity>> call({
    String query = '',
    String format = '',
    String timeRange = '',
  }) async {
    final books = await repository.getDonatedBooks();

    return books.where((book) {
      final matchesQuery = query.isEmpty ||
          book.bookTitle.toLowerCase().contains(query.toLowerCase()) ||
          book.donorName.toLowerCase().contains(query.toLowerCase());

      final matchesFormat = format.isEmpty || book.format.toLowerCase() == format.toLowerCase();

      final matchesTime = _matchesTimeRange(book.createdAt, timeRange);

      return matchesQuery && matchesFormat && matchesTime;
    }).toList();
  }

  bool _matchesTimeRange(String createdAt, String timeRange) {
    if (timeRange.isEmpty) return true;
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);
      switch (timeRange) {
        case 'Today':
          return diff.inDays < 1;
        case 'This Week':
          return diff.inDays < 7;
        case 'This Month':
          return diff.inDays < 30;
        case 'Older':
          return diff.inDays >= 30;
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }
}

//above is an extra feature for filtering
