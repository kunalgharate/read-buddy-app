import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import '../../../../core/network/api_constants.dart';

abstract class BookCrudRemoteDataSource {
  Future<List<BookCrudModel>> getBooks();
  Future<List<BookCrudModel>> searchBooks(String query);
  Future<BookCrudModel> getBookById(String id);
  Future<void> addBook(BookCrudModel book);
  Future<void> updateBook(String id, BookCrudModel book);
  Future<void> deleteBook(String id);
}

@Injectable(as: BookCrudRemoteDataSource)
class BookCrudRemoteDataSourceImpl implements BookCrudRemoteDataSource {
  final Dio dio;

  BookCrudRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookCrudModel>> getBooks() async {
    try {
      final response = await dio.get(ApiConstants.books);

      if (response.statusCode != ApiConstants.success) {
        throw Exception(
            'Failed to load books. Status code: ${response.statusCode}');
      }

      return _parseBookList(response.data);
    } catch (e, stackTrace) {
      print("❌ Error fetching books: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow; // rethrowing allows the error to be handled further up the chain (e.g., in Bloc)
    }
  }

  /// Handles both array and wrapped responses (e.g. { "books": [...] } or { "data": [...] })
  List<BookCrudModel> _parseBookList(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      // Try common wrapper keys
      list = data['books'] ?? data['data'] ?? data['results'] ?? [];
    } else {
      list = [];
    }
    return list.map((json) => BookCrudModel.fromJson(json)).toList();
  }

  @override
  Future<BookCrudModel> getBookById(String id) async {
    try {
      print("📖 Fetching book by ID: $id");

      final response = await dio.get('${ApiConstants.books}/$id');

      if (response.statusCode != 200) {
        throw Exception(
            '❌ Failed to load book details. Status code: ${response.statusCode}');
      }

      print("✅ Book by id  fetched successfully");
      print(response.data);

      // Unwrap { "data": {...} } envelope if present
      final json = response.data is Map<String, dynamic> &&
              response.data.containsKey('data')
          ? response.data['data']
          : response.data;

      return BookCrudModel.fromJson(json);
    } catch (e, stackTrace) {
      print("❌ Error fetching book by ID: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  @override
  Future<void> addBook(BookCrudModel book) async {
    try {
      print("📦 Adding book...");
      final token = await getIt<SecureStorageUtil>().getAccessToken();

      // Build form data matching new API: title, author, publisher, description, categories, tags, coverImage
      final Map<String, dynamic> formMap = {
        "title": book.title,
        "author": book.author,
      };

      if (book.publisher.isNotEmpty) {
        formMap["publisher"] = book.publisher;
      }
      if (book.description.isNotEmpty) {
        formMap["description"] = book.description;
      }

      // Categories as JSON array of ObjectIds
      final categoryId = book.categoryId ?? book.category;
      if (categoryId.isNotEmpty) {
        formMap["categories"] = '["$categoryId"]';
      }

      // Tags as JSON array
      if (book.tags.isNotEmpty) {
        formMap["tags"] = '[${book.tags.map((t) => '"$t"').join(",")}]';
      }

      // Cover image
      if (book.coversingleImage != null) {
        formMap["coverImage"] =
            await MultipartFile.fromFile(book.coversingleImage!.path);
      }

      final formData = FormData.fromMap(formMap);

      print("📦 Sending: title=${book.title}, author=${book.author}");

      final response = await dio.post(
        ApiConstants.books,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
        data: formData,
      );

      print("📨 Response status: ${response.statusCode}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            '❌ Failed to add book. Status code: ${response.statusCode}');
      }

      print("✅ Book added successfully.");
    } catch (e, stackTrace) {
      print("❌ Error adding book: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  @override
  Future<void> updateBook(String id, BookCrudModel book) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();

      final Map<String, dynamic> formMap = {};

      if (book.title.isNotEmpty) formMap['title'] = book.title;
      if (book.author.isNotEmpty) formMap['author'] = book.author;
      if (book.publisher.isNotEmpty) formMap['publisher'] = book.publisher;
      if (book.description.isNotEmpty) {
        formMap['description'] = book.description;
      }

      final categoryId = book.categoryId ?? book.category;
      if (categoryId.isNotEmpty) {
        formMap['categories'] = '["$categoryId"]';
      }

      if (book.tags.isNotEmpty) {
        formMap['tags'] = '[${book.tags.map((t) => '"$t"').join(",")}]';
      }

      if (book.coversingleImage != null) {
        formMap['coverImage'] =
            await MultipartFile.fromFile(book.coversingleImage!.path);
      }

      final formData = FormData.fromMap(formMap);

      final response = await dio.put(
        '${ApiConstants.books}/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update book. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error updating book: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      print("Deleteing book_id $id");
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.delete('${ApiConstants.books}/$id',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      print("Deleteing book $token");
      print(response.statusCode);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.message}");
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  @override
  Future<List<BookCrudModel>> searchBooks(String query) async {
    try {
      print("🔍 Searching books $query");
      final response = await dio.get(
        "${ApiConstants.searchBooks}/$query",
      );

      if (response.statusCode != ApiConstants.success) {
        throw Exception(
            'Failed to load books. Status code: ${response.statusCode}');
      }

      return _parseBookList(response.data);
    } catch (e, stackTrace) {
      print("❌ Error fetching searching books: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow; // rethrowing allows the error to be handled further up the chain (e.g., in Bloc)
    }
  }
}
