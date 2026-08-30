import '../entities/reading_progress_entity.dart';
import '../repositories/reading_progress_repository.dart';

class SaveReadingProgress {
  final ReadingProgressRepository _repository;
  SaveReadingProgress(this._repository);

  Future<void> call(ReadingProgressEntity progress) =>
      _repository.saveProgress(progress);
}

class GetReadingProgress {
  final ReadingProgressRepository _repository;
  GetReadingProgress(this._repository);

  Future<ReadingProgressEntity?> call(String bookId) =>
      _repository.getProgress(bookId);
}

class GetRecentReadingProgress {
  final ReadingProgressRepository _repository;
  GetRecentReadingProgress(this._repository);

  Future<List<ReadingProgressEntity>> call({int limit = 10}) =>
      _repository.getRecent(limit: limit);
}
