import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/donated_books_model.dart';

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
        throw Exception('Failed to load donated books');
      }

      return (response.data as List)
          .map((json) => DonatedBooksModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error occured while fetching donated books: $e');
      rethrow;
    }
  }
}
