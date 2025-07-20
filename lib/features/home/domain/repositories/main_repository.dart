import '../entities/book_entity.dart';

abstract class HomeRepository {
  Future<List<LatestBookEntity>> fetchLatestBooks(String id);
  Future<List<RecommendedBookCardEntity>> fetchRecommendedBooks(String id);
  Future<List<StatEntity>> fetchStats();
  Future<List<BannerEntity>> getBanners();
}
