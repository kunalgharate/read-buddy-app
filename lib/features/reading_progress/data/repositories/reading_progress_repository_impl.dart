import 'package:flutter/foundation.dart';

import '../../domain/entities/reading_progress_entity.dart';
import '../../domain/repositories/reading_progress_repository.dart';
import '../datasources/reading_progress_local_datasource.dart';
import '../datasources/reading_progress_remote_datasource.dart';
import '../models/reading_progress_model.dart';

class ReadingProgressRepositoryImpl implements ReadingProgressRepository {
  final ReadingProgressRemoteDataSource _remote;
  final ReadingProgressLocalDataSource _local;

  ReadingProgressRepositoryImpl(this._remote, this._local);

  @override
  Future<void> saveProgress(ReadingProgressEntity progress) async {
    final model = ReadingProgressModel.fromEntity(progress);

    // Always cache locally first so resume works even offline.
    await _local.cacheProgress(model);

    // Best-effort remote sync — never throw for a background save.
    try {
      await _remote.saveProgress(model);
    } catch (e) {
      if (kDebugMode) print('⚠️ remote saveProgress failed (cached locally): $e');
    }
  }

  @override
  Future<ReadingProgressEntity?> getProgress(String bookId) async {
    try {
      final remote = await _remote.getProgress(bookId);
      if (remote != null) {
        // Keep local cache warm.
        await _local.cacheProgress(remote);
        return remote;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ remote getProgress failed, using cache: $e');
    }
    return _local.getProgress(bookId);
  }

  @override
  Future<List<ReadingProgressEntity>> getRecent({int limit = 10}) async {
    try {
      final remote = await _remote.getRecent(limit: limit);
      if (remote.isNotEmpty) {
        for (final item in remote) {
          await _local.cacheProgress(item);
        }
        return remote;
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ remote getRecent failed, using cache: $e');
    }
    return _local.getRecent(limit: limit);
  }
}
