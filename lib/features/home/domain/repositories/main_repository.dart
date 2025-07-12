import '../entities/book_entity.dart';

abstract class HomeRepository {
  Future<List<LatestBookEntity>> fetchLatestBooks();
  Future<List<RecommendedBookCardEntity>> fetchRecommendedBooks();
  Future<List<StatEntity>> fetchStats();
}
