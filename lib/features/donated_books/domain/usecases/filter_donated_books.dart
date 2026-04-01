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

      final matchesFormat =
          format.isEmpty || book.format.toLowerCase() == format.toLowerCase();

      final matchesTime = _matchesTimeRange(book.createdAt, timeRange);

      return matchesQuery && matchesFormat && matchesTime;
    }).toList();
  }

  bool _matchesTimeRange(String createdAt, String timeRange) {
    if (timeRange.isEmpty) return true;
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      switch (timeRange) {
        case 'Today':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final weekStart =
              DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart);
        case 'This Month':
          return date.year == now.year && date.month == now.month;
        case 'Older':
          return date.year < now.year ||
              (date.year == now.year && date.month < now.month);
        default:
          return true;
      }
    } catch (_) {
      return true;
    }
  }
}

//above is an extra feature for filtering
