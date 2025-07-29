import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/network_utils.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn(
      {required String email, required String password});
  Future<AppUserModel> registerUser(Map<String, dynamic> data);
  Future<AppUserModel> verifyEmail(String email, String code);
  Future<AppUserModel> signInWithGoogle({required String token});
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting sign in API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.login}');
      print('🌐 AuthRemoteDataSource: Email: $email');
    }

    // Check network connectivity before making request
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.login),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final requestData = {
        'email': email.trim().toLowerCase(),
        'password': password,
      };

      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Request data: $requestData');
      }

      final response = await _dio.post(
        ApiConstants.login,
        data: requestData,
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Response status: ${response.statusCode}');
        print('🌐 AuthRemoteDataSource: Response data: ${response.data}');
      }

      if (response.statusCode == ApiConstants.success) {
        final userModel = AppUserModel.fromJson(response.data);

        if (kDebugMode) {
          print('🌐 AuthRemoteDataSource: User model created successfully');
          print('🌐 AuthRemoteDataSource: User name: ${userModel.name}');
        }

        return userModel;
      }

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Login failed with status: ${response.statusCode}');
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login failed with status: ${response.statusCode}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Exception occurred during sign in');
        print('🌐 AuthRemoteDataSource: Exception type: ${e.runtimeType}');
        print('🌐 AuthRemoteDataSource: Exception details: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AppUserModel> registerUser(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting registration API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.register}');
    }

    // Check network connectivity before making request
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.register),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      // Clean and validate data
      final cleanData = {
        ...data,
        'email': data['email']?.toString().trim().toLowerCase(),
        'name': data['name']?.toString().trim(),
      };

      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Clean data: $cleanData');
      }

      final response = await _dio.post(
        ApiConstants.register,
        data: cleanData,
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Registration response status: ${response.statusCode}');
        print(
            '🌐 AuthRemoteDataSource: Registration response data: ${response.data}');
      }

      if (response.statusCode == ApiConstants.success ||
          response.statusCode == ApiConstants.created) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Registration failed',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Registration exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AppUserModel> verifyEmail(String email, String code) async {
    if (kDebugMode) {
      print('🌐 AuthRemoteDataSource: Starting email verification API call');
      print('🌐 AuthRemoteDataSource: URL: ${ApiConstants.verifyEmail}');
    }

    // Check network connectivity before making request
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.verifyEmail),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.verifyEmail,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
        },
      );

      if (kDebugMode) {
        print(
            '🌐 AuthRemoteDataSource: Verification response status: ${response.statusCode}');
      }

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Email verification failed',
      );
    } catch (e) {
      if (kDebugMode) {
        print('🌐 AuthRemoteDataSource: Email verification exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle({required String token}) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginWithGoogle,
        data: {
          'token': token,
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login failed',
      );
    } catch (e) {
      rethrow;
    }
  }
}
