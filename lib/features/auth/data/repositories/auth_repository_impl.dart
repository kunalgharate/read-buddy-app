import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remotesource/auth_remote_data_source.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    try {
      return await remoteDataSource.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser> signInUsingGoogle({required String token}) {
    return remoteDataSource.signInWithGoogle(token: token);
  }

  @override
  Future<AppUser> registerUser(Map<String, dynamic> data) async {
    try {
      return await remoteDataSource.registerUser(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser> verifyEmail(String email, String code) async {
    try {
      return await remoteDataSource.verifyEmail(email, code);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendOtp(String email) async {
    if (kDebugMode) print('📦 AuthRepository: Sending OTP to $email');
    try {
      await remoteDataSource.sendOtp(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyResetOtp(String email, String otp) async {
    if (kDebugMode) print('📦 AuthRepository: Verifying OTP for $email');
    try {
      await remoteDataSource.verifyResetOtp(email, otp);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
      String email, String code, String newPassword) async {
    if (kDebugMode) print('📦 AuthRepository: Changing password for $email');
    try {
      await remoteDataSource.changePassword(email, code, newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
