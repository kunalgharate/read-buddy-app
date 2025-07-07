import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../di/injection.dart';
import '../network/api_constants.dart';
import '../utils/secure_storage_utils.dart';

@injectable
class ImageUploadService {
  final Dio _dio;

  ImageUploadService({required Dio dio}) : _dio = dio;

  /// Upload profile image and return the image URL
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      
      // Create form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadProfileImage, // You'll need to add this endpoint
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns the image URL in response.data['imageUrl']
        return response.data['imageUrl'] ?? response.data['url'] ?? '';
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to upload image',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid image file';
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 413) {
        throw Exception('Image file is too large. Please choose a smaller image.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Validate image file before upload
  bool validateImageFile(File imageFile) {
    // Check file size (max 5MB)
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    if (imageFile.lengthSync() > maxSizeInBytes) {
      throw Exception('Image file is too large. Maximum size is 5MB.');
    }

    // Check file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    final fileExtension = imageFile.path.toLowerCase().split('.').last;
    if (!allowedExtensions.contains('.$fileExtension')) {
      throw Exception('Invalid image format. Please use JPG, PNG, or GIF.');
    }

    return true;
  }
}
