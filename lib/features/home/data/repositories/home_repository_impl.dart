import 'package:injectable/injectable.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/main_repository.dart';
import '../datasources/home_remote_data_source.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LatestBookEntity>> fetchLatestBooks() async {
    final models = await remoteDataSource.fetchLatestBooks();
    return models.map((model) => model.toLatestEntity()).toList();
  }

  @override
  Future<List<RecommendedBookCardEntity>> fetchRecommendedBooks() async {
    final models = await remoteDataSource.fetchRecommendedBooks();
    return models.map((model) => model.toRecommendedEntity()).toList();
  }

  @override
  Future<List<StatEntity>> fetchStats() async {
    final stat = await remoteDataSource.fetchStats();
    return stat.map((model) => model.toEntity()).toList();
  }
}
