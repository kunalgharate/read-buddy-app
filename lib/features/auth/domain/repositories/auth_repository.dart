

import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<dynamic> signInUsingGoogle();
  Future<dynamic> signUp();
  Future<dynamic> forgetPassword();
}
