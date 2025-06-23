// features/books/data/datasources/book_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/data/models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn(
      {required String email, required String password});
  Future<AppUserModel> signInWithGoogle(String idToken);
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AppUserModel> signIn(
      {required String email, required String password}) async {
    final response = await dio
        .post('users/login', data: {'email': email, 'password': password});

    if (response.statusCode != 200) {
      throw Exception('Failed to logged in');
    }
    print('Response data: ${response.data}');
    return AppUserModel.fromJson(response.data);
  }

  @override
  Future<AppUserModel> signInWithGoogle(String idToken) async {
    try {
      final response = await dio.post(
        'users/google-login', // ✅ Replace with your real Google login endpoint
        data: {'idToken': idToken},
      );

      if (response.statusCode != 200) {
        throw Exception('Google sign-in failed');
      }

      return AppUserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
