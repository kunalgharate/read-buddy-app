import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/utils/book_value_items.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/item_model.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/user_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import '../../../../core/network/api_constants.dart';

abstract class BookCrudRemoteDataSource {
  Future<List<BookCrudModel>> getBooks();
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

      return (response.data as List).map((json) {
        // ✅ Safely extract category object from each book
        final categoryJson = json['category'];
        if (categoryJson != null) {
          BookValueItems.bookCategories.add(ItemModel.fromJson(categoryJson));
        }
        return BookCrudModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      print("❌ Error fetching books: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow; // rethrowing allows the error to be handled further up the chain (e.g., in Bloc)
    }
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
      print(response.data['book']);

      return BookCrudModel.fromJson(response.data['book']);
    } catch (e, stackTrace) {
      print("❌ Error fetching book by ID: $e");
      print("🔍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  // @override
  // Future<BookCrudModel> getBookById(String id) async {
  //   print("get book by id.........");
  //   final response = await dio.get('${Api.books}/$id');

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to load book details');
  //   }

  //   return BookCrudModel.fromJson(response.data);
  // }

  // @override
  // Future<void> addBook(BookCrudModel book) async {
  //   try {
  //     print("📦 Adding book...");
  //     print(book.toJson());
  //     final response = await dio.post(
  //       Api.books,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //       data: book.toJson(),
  //     );

  //     print("📨 Response status: ${response.statusCode}");

  //     if (response.statusCode != 201 && response.statusCode != 200) {
  //       throw Exception(
  //           '❌ Failed to add book. Status code: ${response.statusCode}');
  //     }

  //     print("✅ Book added successfully.");
  //   } catch (e, stackTrace) {
  //     print("❌ Error adding book: $e");
  //     print("🔍 StackTrace: $stackTrace");
  //     rethrow;
  //   }
  // }

  @override
  Future<void> addBook(BookCrudModel book) async {
    try {
      print("📦 Adding book...");
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final formData = FormData.fromMap({
        "title": book.title,
        "subtitle": "a book",
        "author": book.author,
        "publisher": book.publisher,
        "publication_year": book.publicationYear.toString(),
        "isbn": book.isbn,
        "edition": "1st",
        "condition": book.condition,
        "format": book.format,
        "language": book.language,
        "genre": book.genre,
        "tags": book.tags.join(","),
        "category": book.category,
        "ownerId": book.ownerId,
        "description": book.description,
        // "coverImage": "4dmwuh.jpg",
        "coverImage": book.coversingleImage?.path ?? "",
        // "coverImage": await MultipartFile.fromFile(
        //   book.coversingleImage!.path,
        //   filename: book.coversingleImage!.path.split('/').last,
        // ),

        "city": "chandigarh",
        "state": "chandigarh",
        "country": "india",
        "pincode": "123467",
        "latitude": "26.77",
        "longitude": "77.88",
        "number_of_copies": book.numberOfCopies.toString(),
        "additionalImages": book.additionalImages.map((file) {
          return file.path.split('/').last;
        }).toList(),

        // "additionalImages":
        //     book.additionalImages.map((f) => f.path.split('/').last).toList(),
      });

      print("formmmmm data");
      print("title: ${book.title}");
      print("subtitle: a book"); // hardcoded
      print("author: ${book.author}");
      print("publisher: ${book.publisher}");
      print("publication_year: ${book.publicationYear}");
      print("isbn: ${book.isbn}");
      print("edition: 1st"); // hardcoded
      print("condition: ${book.condition}");
      print("format: ${book.format}");
      print("language: ${book.language}");
      print("genre: ${book.genre}");
      print("tags: ${book.tags.join(",")}");
      print("category: ${book.category}");
      print("ownerId: ${book.ownerId}");
      print("description: ${book.description}");
      print("coverImage: ${book.coversingleImage}");
      print("city: chandigarh"); // hardcoded
      print("state: chandigarh"); // hardcoded
      print("country: india"); // hardcoded
      print("pincode: 123467"); // hardcoded
      print("latitude: 26.77"); // hardcoded
      print("longitude: 77.88"); // hardcoded
      print("number_of_copies: ${book.numberOfCopies}");
      print(
          "additionalImages: ${book.additionalImages.map((f) => f.path.split('/').last).toList()}");

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
    final response = await dio.put('${ApiConstants.books}/$id', data: book.toJson());

    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
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
}
