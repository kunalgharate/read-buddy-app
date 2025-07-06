import 'dart:io';

import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';

abstract class BannerRemoteDataSource {
  Future<void> createBanner({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final Dio dio;

  BannerRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> createBanner({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  }) async {

    print("Image path: ${bannerImage.path}");
    final fileExists = await bannerImage.exists();
    print("File exists: $fileExists");

    if (!fileExists) {
      print("File does not exist. Cannot proceed.");
      return;
    }

    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final formData = FormData.fromMap({
        'title': title,
        "link": link ?? '',
        'desc': description,
        "bannerType": bannerType,
        'image': await MultipartFile.fromFile(bannerImage.path),
      });
      print("title is: $title");
      print("link is: $link");
      print("description is: $description");
      print("bannerType is: $bannerType");
      print("Image path: ${bannerImage.path}");

      final response = await dio.post(
        ApiConstants.createBanner,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print("Response status: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Unsuccessful response");
        throw Exception('Failed to create banner');
      } else {
        print("Succesfully created banner with title: $title");
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
