// features/category_crud/data/datasources/category_remote_data_source.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import '../../../../../core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/category_crud/data/model/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<void> addCategory({
    required String title,
    required String parentCategory,
    required File image,
  });

  Future<void> updateCategory({
    required String id,
    required String title,
    required String parentCategory,
    File? image,
  });

  Future<void> deleteCategory(String id);
}

@Injectable(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(ApiConstants.categories); // e.g. '/categories'

      print("Fetched categories response");

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories');
      }

      return (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.message}");
        print("Status code: ${e.response?.statusCode}");

        print("Response data: ${e.response?.data}");
      } else {
        print("Unexpected error: $e");
      }
      rethrow; // Optional: if you want the error to propagate up
    }
  }

  @override
  Future<void> addCategory({
    required String title,
    required String parentCategory,
    required File image,
  }) async {
    print("form dataaaaaaaaaaa is ");

    print("Image path: ${image.path}");
    final fileExists = await image.exists();
    print("File exists: $fileExists");

    if (!fileExists) {
      print("File does not exist. Cannot proceed.");
      return;
    }

    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final formData = FormData.fromMap({
        'name': title,
        'description': parentCategory,
        'image': await MultipartFile.fromFile(image.path),
      });
      print("token: $token");
      print("Form data created: $formData");
      print("Sending title: $title");
      print("Sending parent_category: $parentCategory");
      print("Sending file name: ${image.path.split('/').last}");

      final response = await dio.post(
        ApiConstants.categories,
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
        throw Exception('Failed to add category');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.message}");

        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}"); // 👈 this is what we need
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String title,
    required String parentCategory,
    File? image,
  }) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final Map<String, dynamic> formMap = {
        'name': title,
        'description': parentCategory,
      };

      if (image != null) {
        formMap['image'] = await MultipartFile.fromFile(image.path);
      }

      final formData = FormData.fromMap(formMap);

      final response = await dio.put(
        '${ApiConstants.categories}/$id',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update category');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.message}");
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}"); // 👈 this is what we need
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.delete('${ApiConstants.categories}/$id',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete category');
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
