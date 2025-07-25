import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:read_buddy_app/features/auth/data/remotesource/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> signInUsingGoogle({required String token}) async {
    // Call your remote data source to authenticate with Google token
    final userData = await remoteDataSource.signInWithGoogle(token: token);

    // Return the AppUserModel instance as AppUser
    return userData;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> registerUser(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> verifyEmail(String email, String code) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> forgetPassword() {
    throw UnimplementedError();
  }
}
