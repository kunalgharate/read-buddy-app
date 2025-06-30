// features/books/data/datasources/book_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
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
      print("getBooks() calling...");
      final response = await dio.get(Api.books);
      print("Status Code: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception('Failed to load books');
      }

      print('Response data: ${response.data}');
      return (response.data as List)
          .map((json) => BookModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error occurred while fetching books: $e');
      return []; // Return an empty list on error to avoid crashes
    }
  }
}
// TODO Implement this library.
