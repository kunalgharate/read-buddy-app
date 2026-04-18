import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/network_utils.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../model/home_book_model.dart';
import '../model/home_monthly_status_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BookModel>> getLatestBooks();
  Future<List<BookModel>> getTrendingBooks();
  Future<List<BookModel>> getRecommendedBooks();
  Future<MonthlyStatsModel> getMonthlyStats();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;
  final SecureStorageUtil _secureStorage;

  HomeRemoteDataSourceImpl({
    required Dio dio,
    required SecureStorageUtil secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  Future<Options> _authOptions() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        message: 'No access token available. Please log in again.',
      );
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> _checkInternet(String path) async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }
  }

  List<BookModel> _parseBookList(dynamic data, String endpoint) {
    if (data is! List) {
      throw Exception(
          'Unexpected response format from $endpoint: expected a list');
    }
    return data
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  bool _isSuccess(int? statusCode) =>
      statusCode == ApiConstants.success || statusCode == ApiConstants.created;

  @override
  Future<List<BookModel>> getLatestBooks() async {
    if (kDebugMode) {
      print('🌐 HomeRemoteDataSource: Fetching latest books');
      print('🌐 URL: ${ApiConstants.latestBooks}');
    }

    await _checkInternet(ApiConstants.latestBooks);

    try {
      final response = await _dio.get(
        ApiConstants.latestBooks,
        options: await _authOptions(),
      );

      if (kDebugMode) {
        print(
            '🌐 HomeRemoteDataSource: latestBooks status: ${response.statusCode}');
      }

      if (_isSuccess(response.statusCode)) {
        return _parseBookList(response.data, ApiConstants.latestBooks);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch latest books',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 HomeRemoteDataSource: getLatestBooks exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<BookModel>> getTrendingBooks() async {
    if (kDebugMode) {
      print('🌐 HomeRemoteDataSource: Fetching trending books');
      print('🌐 URL: ${ApiConstants.trendingBooks}');
    }

    await _checkInternet(ApiConstants.trendingBooks);

    try {
      final response = await _dio.get(
        ApiConstants.trendingBooks,
        options: await _authOptions(),
      );

      if (kDebugMode) {
        print(
            '🌐 HomeRemoteDataSource: trendingBooks status: ${response.statusCode}');
      }

      if (_isSuccess(response.statusCode)) {
        final books = _parseBookList(response.data, ApiConstants.trendingBooks);
        if (kDebugMode) {
          print('📚 trendingBooks count: ${books.length}');
        }
        return books;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch trending books',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 HomeRemoteDataSource: getTrendingBooks exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<BookModel>> getRecommendedBooks() async {
    await _checkInternet(ApiConstants.recommendedBooks);

    try {
      final response = await _dio.get(
        ApiConstants.recommendedBooks,
        options: await _authOptions(),
      );

      if (_isSuccess(response.statusCode)) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          throw Exception('Unexpected response format from recommendedBooks');
        }
        final mostRequested = data['mostRequested'];
        if (mostRequested is! List || mostRequested.isEmpty) {
          return [];
        }
        return mostRequested
            .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch recommended books',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 HomeRemoteDataSource: getRecommendedBooks exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<MonthlyStatsModel> getMonthlyStats() async {
    await _checkInternet(ApiConstants.monthlyData);

    try {
      final response = await _dio.get(
        ApiConstants.monthlyData,
        options: await _authOptions(),
      );

      if (_isSuccess(response.statusCode)) {
        return MonthlyStatsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch monthly stats',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 HomeRemoteDataSource: getMonthlyStats exception: $e');
      }
      rethrow;
    }
  }
}
