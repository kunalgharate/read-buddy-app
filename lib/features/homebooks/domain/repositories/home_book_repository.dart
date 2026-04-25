import '../entities/book_entity.dart';

abstract class HomeRepository {
  Future<List<BookEntity>> getLatestBooks();
  Future<List<BookEntity>> getTrendingBooks();
  Future<List<BookEntity>> getRecommendedBooks(); // ← returns a list
}
