import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_constants.dart';
import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn(
      {required String email, required String password});
  Future<AppUserModel> signInWithGoogle({required String token});
  Future<AppUserModel> registerUser(Map<String, dynamic> data);
  Future<AppUserModel> verifyEmail(String email, String code);
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
        message: 'Login failed',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUserModel> registerUser(Map<String, dynamic> data) async {
    try {
      // Clean and validate data
      final cleanData = {
        ...data,
        'email': data['email']?.toString().trim().toLowerCase(),
        'name': data['name']?.toString().trim(),
      };

      final response = await _dio.post(
        ApiConstants.register,
        data: cleanData,
      );

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
