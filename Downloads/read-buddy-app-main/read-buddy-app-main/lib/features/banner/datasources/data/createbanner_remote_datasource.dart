import 'dart:io';

import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/banner/datasources/model/banner_model.dart';

abstract class BannerRemoteDataSource {
  Future<List<BannerModel>> getBannerList();

  Future<void> createBanner({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });

  Future<void> updateBanner({
    required String id,
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });

  Future<void> deleteBanner({
    required String id,
  });
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final Dio dio;

  BannerRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BannerModel>> getBannerList() async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.get(
        ApiConstants.Banner,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Response status: ${response.statusCode}");
      print("Response status: ${response.data}");
      if (response.statusCode != 200 && response.statusCode != 204) {
        print("Unsuccessful response");

        throw Exception('Failed to Getbanner list');
      } else {
        final List<dynamic> payload = response.data;
        return payload.map((e) => BannerModel.fromJson(e)).toList();
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
    return [];
  }

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
        ApiConstants.Banner,
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

  //Delete Banner

  @override
  Future<void> deleteBanner({required String id}) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.delete(
        '${ApiConstants.Banner}/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Response status: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        print("Unsuccessful response");
        throw Exception('Failed to delete banner');
      } else {
        print("Successfully deleted banner with id: $id");
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

  //Update Banner

  @override
  Future<void> updateBanner({
    required String id,
    required String title,
    String? link,
    String? description,
    required String bannerType,
    File? bannerImage, // ✅ make it nullable
  }) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();

      // ✅ Build formData dynamically
      final Map<String, dynamic> data = {
        'title': title,
        "link": link ?? '',
        'desc': description ?? '',
        "bannerType": bannerType,
      };

      if (bannerImage != null && await bannerImage.exists()) {
        data['image'] = await MultipartFile.fromFile(bannerImage.path);
        print("New image selected: ${bannerImage.path}");
      } else {
        print("No new image selected, keeping existing one.");
      }

      final formData = FormData.fromMap(data);

      print("Updating banner with data: $data");

      final response = await dio.put(
        "${ApiConstants.Banner}/$id",
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
        throw Exception('Failed to update banner');
      } else {
        print("Successfully updated banner: $title");
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
