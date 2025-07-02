// features/books/data/repositories/book_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

import '../../domain/repositories/auth_repository.dart';
import '../remotesource/auth_remote_data_source.dart';
import 'package:read_buddy_app/features/auth/data/google_auth/sign_in_with_google.dart';

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
  // Future signInUsingGoogle() {
  //   // TODO: implement signInUsingGoogle
  //   throw UnimplementedError();
  // }

  @override
  Future signUp() {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
<<<<<<< Updated upstream
=======
  Future<AppUser> verifyEmail(String email, String code) {
    return remoteDataSource.verifyEmail(email, code);
  }

  @override
>>>>>>> Stashed changes
  Future<AppUser> signIn({required String email, required String password}) {
    return remoteDataSource.signIn(email: email, password: password);
  }

  @override
  Future<AppUser> signInUsingGoogle() async {
    final result = await SignInWithGoogle().signInWithGoogle();
    final account = result?.account;

    if (account == null) throw Exception("Google Sign-In failed");

    return AppUser(
      id: '',
      name: account.displayName ?? '',
      email: account.email,
      password: '',
      role: 'user',
      isPrime: false,
      finesDue: 0,
      isEmailVerified: true,
      badges: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 1,
      accessToken: '',
      refreshToken: '',
      picture: account.photoUrl,
      phno: '',
      wishlist: [],
    );
  }
}
