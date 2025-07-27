import 'package:injectable/injectable.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/main_repository.dart';
import '../datasources/home_remote_data_source.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LatestBookEntity>> fetchLatestBooks(String id) async {
    final models = await remoteDataSource.fetchLatestBooks(id);
    return models.map((model) => model.toLatestEntity()).toList();
  }

  @override
  Future<List<RecommendedBookCardEntity>> fetchRecommendedBooks(
      String id) async {
    final models = await remoteDataSource.fetchRecommendedBooks(id);
    return models.map((model) => model.toRecommendedEntity()).toList();
  }

  @override
  Future<List<StatEntity>> fetchStats() async {
    final stat = await remoteDataSource.fetchStats();
    return stat.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<BannerEntity>> getBanners() async {
    final banners = await remoteDataSource.fetchBanners();
    return banners.map((e) => e.toEntity()).toList();
  }
}
