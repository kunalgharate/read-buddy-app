import '../entities/reading_progress_entity.dart';

abstract class ReadingProgressRepository {
  /// Persist progress locally (instant) and best-effort sync to the backend.
  Future<void> saveProgress(ReadingProgressEntity progress);

  /// Resolve saved progress for a book. Prefers remote (cross-device), falls
  /// back to the local cache when offline / on error.
  Future<ReadingProgressEntity?> getProgress(String bookId);

  /// Recently read items across formats (most-recent first).
  Future<List<ReadingProgressEntity>> getRecent({int limit});
}
