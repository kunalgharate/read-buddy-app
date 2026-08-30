import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_progress_model.dart';

/// Local (offline-first) cache for reading progress. Progress is written here
/// synchronously so the reader can restore position instantly and even without
/// a network connection; the remote datasource is best-effort synced on top.
abstract class ReadingProgressLocalDataSource {
  Future<void> cacheProgress(ReadingProgressModel progress);
  Future<ReadingProgressModel?> getProgress(String bookId);
  Future<List<ReadingProgressModel>> getRecent({int limit});
}

class ReadingProgressLocalDataSourceImpl
    implements ReadingProgressLocalDataSource {
  static const String _keyPrefix = 'reading_progress_';
  static const String _indexKey = 'reading_progress_index';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _key(String bookId) => '$_keyPrefix$bookId';

  @override
  Future<void> cacheProgress(ReadingProgressModel progress) async {
    try {
      final prefs = await _prefs;
      final withTime = progress.lastReadAt == null
          ? ReadingProgressModel.fromEntity(
              progress.copyWith(lastReadAt: DateTime.now()))
          : progress;
      await prefs.setString(_key(progress.bookId), jsonEncode(withTime.toJson()));

      // Maintain an ordered index of bookIds (most-recent first).
      final index = prefs.getStringList(_indexKey) ?? <String>[];
      index.remove(progress.bookId);
      index.insert(0, progress.bookId);
      await prefs.setStringList(_indexKey, index.take(50).toList());
    } catch (e) {
      if (kDebugMode) print('⚠️ cacheProgress failed: $e');
    }
  }

  @override
  Future<ReadingProgressModel?> getProgress(String bookId) async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_key(bookId));
      if (raw == null) return null;
      return ReadingProgressModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (e) {
      if (kDebugMode) print('⚠️ local getProgress failed: $e');
      return null;
    }
  }

  @override
  Future<List<ReadingProgressModel>> getRecent({int limit = 10}) async {
    try {
      final prefs = await _prefs;
      final index = prefs.getStringList(_indexKey) ?? <String>[];
      final results = <ReadingProgressModel>[];
      for (final bookId in index) {
        final p = await getProgress(bookId);
        if (p != null) results.add(p);
        if (results.length >= limit) break;
      }
      return results;
    } catch (e) {
      if (kDebugMode) print('⚠️ local getRecent failed: $e');
      return const [];
    }
  }
}
