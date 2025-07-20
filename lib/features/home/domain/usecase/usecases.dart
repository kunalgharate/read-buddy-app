import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

import '../entities/book_entity.dart';
import '../repositories/main_repository.dart';

@injectable
class GetLatestBooksUseCase {
  final HomeRepository repository;

  GetLatestBooksUseCase(this.repository);

  Future<List<LatestBookEntity>> call(String id) async {
    final models = await repository.fetchLatestBooks(id);
    return models;
  }
}

@injectable
class GetRecommendedBooksUseCase {
  final HomeRepository repository;

  GetRecommendedBooksUseCase(this.repository);

  Future<List<RecommendedBookCardEntity>> call(String id) async {
    final bookModels = await repository.fetchRecommendedBooks(id);
    return bookModels;
  }
}

@injectable
class GetStatsUseCase {
  final HomeRepository repository;

  GetStatsUseCase(this.repository);

  Future<List<StatEntity>> call() async {
    final stats = await repository.fetchStats();
    return stats;
  }
}

@injectable
class GetBannersUseCase {
  final HomeRepository repository;
  GetBannersUseCase(this.repository);

  Future<List<BannerEntity>> call() async => await repository.getBanners();
}
