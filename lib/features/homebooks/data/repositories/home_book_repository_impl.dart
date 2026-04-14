import 'package:flutter/foundation.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/home_book_repository.dart';

import '../datasource/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<BookEntity>> getLatestBooks() async {
    try {
      final result = await _remoteDataSource.getLatestBooks();
      if (kDebugMode)
        print('✅ HomeRepository: getLatestBooks → ${result.length} books');
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ HomeRepository: getLatestBooks failed → $e');
      rethrow;
    }
  }

  @override
  Future<List<BookEntity>> getTrendingBooks() async {
    try {
      final result = await _remoteDataSource.getTrendingBooks();
      if (kDebugMode)
        print('✅ HomeRepository: getTrendingBooks → ${result.length} books');
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ HomeRepository: getTrendingBooks failed → $e');
      rethrow;
    }
  }

  @override
  Future<List<BookEntity>> getRecommendedBook() async {
    try {
      final result = await _remoteDataSource.getRecommendedBook();
      if (kDebugMode)
        print('✅ HomeRepository: getRecommendedBook → ${result.length} books');
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ HomeRepository: getRecommendedBook failed → $e');
      rethrow;
    }
  }
}
