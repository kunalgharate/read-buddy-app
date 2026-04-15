import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../auth/domain/entities/app_user.dart';

abstract class ProfileRemoteDataSource {
  Future<AppUser> updateProfile({required Map<String, String> profileData});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  final SecureStorageUtil _secureStorage;

  ProfileRemoteDataSourceImpl({
    required Dio dio,
    required SecureStorageUtil secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  Future<Options> _authOptions() async {
    final token = await _secureStorage.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<AppUser> updateProfile(
      {required Map<String, String> profileData}) async {
    if (kDebugMode) {
      print('🌐 ProfileRemoteDataSource: Updating profile → $profileData');
    }

    try {
      final response = await _dio.put(
        ApiConstants.updateUserInfo,
        data: profileData,
        options: await _authOptions(),
      );

      if (response.statusCode == ApiConstants.success) {
        return AppUser.fromJson(response.data);
      }

      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ProfileRemoteDataSource: updateProfile exception: $e');
      }
      rethrow;
    }
  }
}
