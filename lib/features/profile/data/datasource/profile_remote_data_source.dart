import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/network_utils.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../model/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUserModel> getProfile();
  Future<ProfileUserModel> updateAvatar(String avatarName);
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
    if (kDebugMode) print('🔑 ProfileRemoteDataSource: Token: $token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  void _checkInternet(String path) async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }
  }

  @override
  Future<ProfileUserModel> getProfile() async {
    if (kDebugMode) {
      print('🌐 ProfileRemoteDataSource: Fetching profile');
      print('🌐 URL: ${ApiConstants.getProfile}');
    }

    _checkInternet(ApiConstants.getProfile);

    try {
      final response = await _dio.get(
        ApiConstants.getProfile,
        options: await _authOptions(),
      );

      if (kDebugMode) {
        print(
            '🌐 ProfileRemoteDataSource: getProfile status: ${response.statusCode}');
        print('🌐 ProfileRemoteDataSource: getProfile data: ${response.data}');
      }

      if (response.statusCode == ApiConstants.success) {
        return ProfileUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch profile',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ProfileRemoteDataSource: getProfile exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ProfileUserModel> updateAvatar(String avatarName) async {
    if (kDebugMode) {
      print('🌐 ProfileRemoteDataSource: Updating avatar → $avatarName');
      print('🌐 URL: ${ApiConstants.updateAvatar}');
    }

    _checkInternet(ApiConstants.updateAvatar);

    try {
      final response = await _dio.patch(
        ApiConstants.updateAvatar,
        data: {'userAvatar': avatarName},
        options: await _authOptions(),
      );

      if (kDebugMode) {
        print(
            '🌐 ProfileRemoteDataSource: updateAvatar status: ${response.statusCode}');
      }

      if (response.statusCode == ApiConstants.success) {
        return ProfileUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to update avatar',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ProfileRemoteDataSource: updateAvatar exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> updateProfile(
      {required Map<String, String> profileData}) async {
    if (kDebugMode) {
      print('🌐 ProfileRemoteDataSource: Updating profile → $profileData');
      print('🌐 URL: ${ApiConstants.updateUserInfo}');
    }

    _checkInternet(ApiConstants.updateUserInfo);

    try {
      final response = await _dio.put(
        ApiConstants.updateUserInfo,
        data: profileData,
        options: await _authOptions(),
      );

      if (kDebugMode) {
        print(
            '🌐 ProfileRemoteDataSource: updateProfile status: ${response.statusCode}');
      }

      if (response.statusCode == ApiConstants.success) {
        return AppUser.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to update profile',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ProfileRemoteDataSource: updateProfile exception: $e');
      }
      rethrow;
    }
  }
}
