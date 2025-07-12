import 'dart:async';
import 'package:injectable/injectable.dart';

import '../entities/book_entity.dart';
import '../repositories/main_repository.dart';

@injectable
class GetLatestBooksUseCase {
  final HomeRepository repository;

  GetLatestBooksUseCase(this.repository);

  Future<List<LatestBookEntity>> call() async {
    final models = await repository.fetchLatestBooks();
    return models;
  }
}

@injectable
class GetRecommendedBooksUseCase {
  final HomeRepository repository;

  GetRecommendedBooksUseCase(this.repository);

  Future<List<RecommendedBookCardEntity>> call() async {
    final bookModels = await repository.fetchRecommendedBooks();
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
