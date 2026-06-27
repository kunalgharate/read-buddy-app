// features/books/data/datasources/book_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks();
}

@Injectable(as: BookRemoteDataSource)
class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final Dio dio;

  BookRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookModel>> getBooks() async {
    try {
      final response = await dio.get(ApiConstants.books);

      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load books');
      }

      final dynamic rawData = response.data;
      final List<dynamic> list;

      if (rawData is Map<String, dynamic> && rawData.containsKey('books')) {
        list = rawData['books'] as List<dynamic>;
      } else if (rawData is Map<String, dynamic> &&
          rawData.containsKey('data')) {
        list = rawData['data'] as List<dynamic>;
      } else if (rawData is List) {
        list = rawData;
      } else {
        throw Exception('Unexpected response format for books');
      }

      return list.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      print('Error occurred while fetching books: $e');
      return []; // Return an empty list on error to avoid crashes
    }
  }
}
