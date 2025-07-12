// import 'package:dio/dio.dart';
// import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

import '../models/home_response_model.dart';
import 'package:injectable/injectable.dart';

abstract class HomeRemoteDataSource {
  Future<List<BookResponseModel>> fetchLatestBooks();
  Future<List<BookResponseModel>> fetchRecommendedBooks();
  Future<List<StatModel>> fetchStats();
}

// @LazySingleton(as: HomeRemoteDataSource)
// class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
//   final Dio dio;

//   HomeRemoteDataSourceImpl(this.dio);

//   @override
//   Future<List<BookResponseModel>> fetchLatestBooks() async {
//     try {
//       final response = await dio.get(
//           'https://readbuddy-server.onrender.com/api/books/category/681f8b856e125f20d6d81647');
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((json) => BookResponseModel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load latest books');
//       }
//     } catch (e) {
//       throw Exception('Error fetching latest books: $e');
//     }
//   }

//   @override
//   Future<List<BookResponseModel>> fetchRecommendedBooks() async {
//     try {
//       final response = await dio.get('books/recommended');
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((json) => BookResponseModel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load recommended books');
//       }
//     } catch (e) {
//       throw Exception('Error fetching recommended books: $e');
//     }
//   }

//   @override
//   Future<List<StatModel>> fetchStats() async {
//     try {
//       final response =
//           await dio.get('https://readbuddy-server.onrender.com/api/books');
//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         return data.map((json) => StatModel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load stats');
//       }
//     } catch (e) {
//       throw Exception('Error fetching stats: $e');
//     }
//   }
// }

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<BookResponseModel>> fetchLatestBooks() async {
    await Future.delayed(Duration(milliseconds: 300));
    return [
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "Wings of Fire",
        category: "Biography",
        donor: "Rahul Sir",
        format: "E Book",
        duration: "3 Days",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
    ];
  }

  @override
  Future<List<BookResponseModel>> fetchRecommendedBooks() async {
    await Future.delayed(Duration(milliseconds: 300));
    return [
      BookResponseModel(
        title: "The God Of Small Things",
        category: "Fiction",
        donor: "Sameer Sir",
        format: "Audio",
        duration: "30:00",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "The God Of Small Things",
        category: "Fiction",
        donor: "Sameer Sir",
        format: "Audio",
        duration: "30:00",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "The God Of Small Things",
        category: "Fiction",
        donor: "Sameer Sir",
        format: "Audio",
        duration: "30:00",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "The God Of Small Things",
        category: "Fiction",
        donor: "Sameer Sir",
        format: "Audio",
        duration: "30:00",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
      BookResponseModel(
        title: "The God Of Small Things",
        category: "Fiction",
        donor: "Sameer Sir",
        format: "Audio",
        duration: "30:00",
        imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
        formatUrl: 'assets/icons/Fiction.png',
      ),
    ];
  }

  @override
  Future<List<StatModel>> fetchStats() async {
    await Future.delayed(Duration(milliseconds: 300));
    return [
      StatModel(
        bookDonated: '75',
        activeUsers: "67",
        deleveries: '5',
      )
    ];
  }
}
