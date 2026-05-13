import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/donated_books/data/models/donated_books_model.dart';

abstract class DonatedBooksRemoteDataSource {
  Future<List<DonatedBooksModel>> getDonatedBooks();
}

@Injectable(as: DonatedBooksRemoteDataSource)
class DonatedBooksRemoteDataSourceImpl implements DonatedBooksRemoteDataSource {
  final Dio dio;

  DonatedBooksRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<DonatedBooksModel>> getDonatedBooks() async {
    try {
      final response = await dio.get(ApiConstants.getAllDonations);

      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load donated books: ${response.statusCode}');
      }

      final data = response.data;

      // Handle different response structures
      if (data is List) {
        // Direct array response
        return data
            .map((json) =>
                DonatedBooksModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        // Nested response with success flag
        if (data.containsKey('success') && data['success'] == true) {
          final donations = data['donations'] ?? data['data'] ?? [];
          return (donations as List)
              .map((json) =>
                  DonatedBooksModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('donations')) {
          // Direct donations key
          return (data['donations'] as List)
              .map((json) =>
                  DonatedBooksModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Unexpected response format');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error occurred while fetching donated books: $e');
      rethrow;
    }
  }
}
