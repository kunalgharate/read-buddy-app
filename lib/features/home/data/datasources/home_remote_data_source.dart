import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../models/home_response_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BookResponseModel>> fetchLatestBooks(String id);
  Future<List<BookResponseModel>> fetchRecommendedBooks(String id);
  Future<List<StatModel>> fetchStats();
  Future<List<BannerModel>> fetchBanners();
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
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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

  @override
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final token = await storageUtil.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception(
            'Access token not available. User might not be logged in.');
      }

      final response = await dio.get(
        'https://readbuddy-server.onrender.com/api/banners',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      print('⚠️ Error fetching banners: $e');
      throw Exception('Error fetching banners: $e');
    }
  }
}
//  