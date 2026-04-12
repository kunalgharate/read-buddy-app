import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signInUsingGoogle({required String token});
  Future<AppUser> registerUser(Map<String, dynamic> data);
  Future<AppUser> verifyEmail(String email, String code);
  Future<void> sendOtp(String email);
  Future<void> verifyResetOtp(String email, String otp);
  Future<void> changePassword(String email, String code, String newPassword);
}