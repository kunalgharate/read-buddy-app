import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/network_utils.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn({required String email, required String password});
  Future<AppUserModel> registerUser(Map<String, dynamic> data);
  Future<AppUserModel> verifyEmail(String email, String code);
  Future<AppUserModel> signInWithGoogle({required String token});
  Future<void> sendOtp(String email);
  Future<void> verifyResetOtp(String email, String otp);
  Future<void> changePassword(String email, String code, String newPassword);
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

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.login),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Login failed with status: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUserModel> registerUser(Map<String, dynamic> data) async {
    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.register),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final cleanData = {
        ...data,
        'email': data['email']?.toString().trim().toLowerCase(),
        'name': data['name']?.toString().trim(),
      };

      final response = await _dio.post(ApiConstants.register, data: cleanData);

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
      rethrow;
    }
  }

  @override
  Future<AppUserModel> verifyEmail(String email, String code) async {
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

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Email verification failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUserModel> signInWithGoogle({required String token}) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginWithGoogle,
        data: {'token': token},
      );

      if (response.statusCode == ApiConstants.success) {
        return AppUserModel.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Google login failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendOtp(String email) async {
    if (kDebugMode) print('🌐 AuthRemoteDataSource: Sending OTP to $email');

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.resendResetOtp),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.resendResetOtp,
        data: {'email': email.trim().toLowerCase()},
      );

      if (kDebugMode) print('🌐 AuthRemoteDataSource: OTP sent ${response.statusCode}');

      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to send OTP',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyResetOtp(String email, String otp) async {
    if (kDebugMode) print('🌐 AuthRemoteDataSource: Verifying OTP for $email');

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.verifyOtp),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'code': otp.trim(),
        },
      );

      if (kDebugMode) print('🌐 AuthRemoteDataSource: OTP verified ${response.statusCode}');

      if (response.statusCode != ApiConstants.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'OTP verification failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
      String email, String code, String newPassword) async {
    if (kDebugMode) print('🌐 AuthRemoteDataSource: Changing password for $email');

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConstants.changePassword),
        type: DioExceptionType.connectionError,
        message: 'No internet connection available',
      );
    }

    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );

      if (kDebugMode) print('🌐 AuthRemoteDataSource: Password changed ${response.statusCode}');

      if (response.statusCode != ApiConstants.success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Password change failed',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}