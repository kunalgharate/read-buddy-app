

import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<dynamic> signInUsingGoogle();
  Future<AppUser> registerUser(Map<String, dynamic> data);
  Future<AppUser> verifyEmail(String email, String code);
  Future<dynamic> forgetPassword();
}
