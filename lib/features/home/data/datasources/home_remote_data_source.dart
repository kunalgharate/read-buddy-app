import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../models/home_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BookResponseModel>> fetchLatestBooks(String id);
  Future<List<BookResponseModel>> fetchRecommendedBooks(String id);
  Future<List<StatModel>> fetchStats();
}

@LazySingleton(as: HomeRemoteDataSource)
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  final SecureStorageUtil storageUtil;

  HomeRemoteDataSourceImpl(this.dio, this.storageUtil);
  @override
  Future<List<BookResponseModel>> fetchLatestBooks(String id) async {
    try {
      final response = await dio.get(
        'https://readbuddy-server.onrender.com/api/getmostrequestedbook/$id',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print("📘 Latest books fetched: $data");
        return data.map((json) => BookResponseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load latest books');
      }
    } catch (e) {
      print('⚠️ Error fetching latest books: $e');
      throw Exception('Error fetching latest books: $e');
    }
  }

  @override
  Future<List<BookResponseModel>> fetchRecommendedBooks(String id) async {
    try {
      final token = await storageUtil.getAccessToken();
      print("Token is $token");
      if (token == null || token.isEmpty) {
        throw Exception(
            'Access token not available. User might not be logged in.');
      }

      final response = await dio.get(
        'https://readbuddy-server.onrender.com/api/recommend/$id',
        // options: Options(
        //   headers: {
        //     'Authorization': 'Bearer $token',
        //   },
        // ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['recommended'];
        print("📘 Recommended books fetched: $data");

        return data.map((json) => BookResponseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended books');
      }
    } catch (e) {
      print('⚠️ Error fetching recommended books: $e');
      throw Exception('Error fetching recommended books: $e');
    }
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
//   @override
//   Future<List<StatModel>> fetchStats() async {
//     try {
//       final response =
//           await dio.get('https://readbuddy-server.onrender.com/api/stats');

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

// Future<List<BookResponseModel>> fetchLatestBooks(String id) async {
//   await Future.delayed(Duration(milliseconds: 300));
//   return [
//     BookResponseModel(
//       id: 'book1',
//       title: "Wings of Fire",
//       category: "Biography",
//       donor: "Rahul Sir",
//       format: "E Book",
//       duration: "3 Days",
//       imageUrl: 'https://example.com/images/wings_of_fire.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//     BookResponseModel(
//       id: 'book2',
//       title: "The Alchemist",
//       category: "Fiction",
//       donor: "Paulo Coelho",
//       format: "Audio",
//       duration: "5 Days",
//       imageUrl: 'https://example.com/images/the_alchemist.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//     BookResponseModel(
//       id: 'book3',
//       title: "1984",
//       category: "Dystopian",
//       donor: "George Orwell",
//       format: "E Book",
//       duration: "4 Days",
//       imageUrl: 'https://example.com/images/1984.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//     BookResponseModel(
//       id: 'book4',
//       title: "To Kill a Mockingbird",
//       category: "Classic",
//       donor: "Harper Lee",
//       format: "Audio",
//       duration: "6 Days",
//       imageUrl: 'https://example.com/images/to_kill_a_mockingbird.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//     BookResponseModel(
//       id: 'book5',
//       title: "The Great Gatsby",
//       category: "Classic",
//       donor: "F. Scott Fitzgerald",
//       format: "E Book",
//       duration: "3 Days",
//       imageUrl: 'https://example.com/images/the_great_gatsby.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//     BookResponseModel(
//       id: 'book6',
//       title: "Moby Dick",
//       category: "Adventure",
//       donor: "Herman Melville",
//       format: "Audio",
//       duration: "7 Days",
//       imageUrl: 'https://example.com/images/moby_dick.jpg',
//       formatUrl: 'assets/icons/Fiction.png',
//     ),
//   ];
// }

//   @override
//   Future<List<BookResponseModel>> fetchRecommendedBooks(String id) async {
//     await Future.delayed(Duration(milliseconds: 300));
//     return [
//       BookResponseModel(
//         id: id,
//         title: "The God Of Small Things",
//         category: "Fiction",
//         donor: "Sameer Sir",
//         format: "Audio",
//         duration: "30:00",
//         imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
//         formatUrl: 'assets/icons/Fiction.png',
//       ),
//       BookResponseModel(
//         id: id,
//         title: "The God Of Small Things",
//         category: "Fiction",
//         donor: "Sameer Sir",
//         format: "Audio",
//         duration: "30:00",
//         imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
//         formatUrl: 'assets/icons/Fiction.png',
//       ),
//       BookResponseModel(
//         id: id,
//         title: "The God Of Small Things",
//         category: "Fiction",
//         donor: "Sameer Sir",
//         format: "Audio",
//         duration: "30:00",
//         imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
//         formatUrl: 'assets/icons/Fiction.png',
//       ),
//       BookResponseModel(
//         id: id,
//         title: "The God Of Small Things",
//         category: "Fiction",
//         donor: "Sameer Sir",
//         format: "Audio",
//         duration: "30:00",
//         imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
//         formatUrl: 'assets/icons/Fiction.png',
//       ),
//       BookResponseModel(
//         id: id,
//         title: "The God Of Small Things",
//         category: "Fiction",
//         donor: "Sameer Sir",
//         format: "Audio",
//         duration: "30:00",
//         imageUrl: 'assets/icons/Screenshot 2025-06-30 111125.png',
//         formatUrl: 'assets/icons/Fiction.png',
//       ),
//     ];
//   }

//   @override
//   Future<List<StatModel>> fetchStats() async {
//     await Future.delayed(Duration(milliseconds: 300));
//     return [
//       StatModel(
//         bookDonated: '75',
//         activeUsers: "67",
//         deleveries: '5',
//       )
//     ];
//   }
// }
