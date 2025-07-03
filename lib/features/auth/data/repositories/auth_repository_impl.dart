// features/books/data/repositories/book_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

import '../../domain/repositories/auth_repository.dart';
import '../remotesource/auth_remote_data_source.dart';


@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future forgetPassword() {
    // TODO: implement forgetPassword
    throw UnimplementedError();
  }


  // @override
  // Future<AppUser> signInUsingGoogle(String token) {
  //   return remoteDataSource.signInWithGoogle(token: token);
  // }

  @override
  Future<AppUser> registerUser(Map<String, dynamic> data) {
    return remoteDataSource.registerUser(data);
  }

  @override
  Future<AppUser> verifyEmail(String email, String code) {
    return remoteDataSource.verifyEmail(email, code);
  }
  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<AppUser> signInUsingGoogle({required String token}) {
    return remoteDataSource.signInWithGoogle(token: token);
  }
}
