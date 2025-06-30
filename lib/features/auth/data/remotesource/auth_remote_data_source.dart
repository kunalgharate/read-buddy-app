// features/books/data/datasources/book_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/data/models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn(
      {required String email, required String password});
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AppUserModel> signIn(
      {required String email, required String password}) async {
    print("login api");
    final response = await dio
        .post('https://readbuddy-server.onrender.com/api/users/login', data: {'email': email, 'password': password});

    if (response.statusCode != 200) {
      throw Exception('Failed to logged in');
    }
    print('Response data: ${response.data}');
    return AppUserModel.fromJson(response.data);
  }
}
