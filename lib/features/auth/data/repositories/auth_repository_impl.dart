// features/books/data/repositories/book_repository_impl.dart
import 'package:flutter/foundation.dart';
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


  @override
  Future<AppUser> registerUser(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('📦 AuthRepository: Starting user registration');
    }

    try {
      final result = await remoteDataSource.registerUser(data);

      if (kDebugMode) {
        print('📦 AuthRepository: Registration successful');
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        print('📦 AuthRepository: Registration failed - $error');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> verifyEmail(String email, String code) async {
    if (kDebugMode) {
      print('📦 AuthRepository: Starting email verification');
    }

    try {
      final result = await remoteDataSource.verifyEmail(email, code);

      if (kDebugMode) {
        print('📦 AuthRepository: Email verification successful');
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        print('📦 AuthRepository: Email verification failed - $error');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    if (kDebugMode) {
      print('📦 AuthRepository: Starting sign in');
      print('📦 AuthRepository: Email: $email');
    }

    try {
      final result = await remoteDataSource.signIn(email: email, password: password);

      if (kDebugMode) {
        print('📦 AuthRepository: Sign in successful');
        print('📦 AuthRepository: User: ${result.name}');
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        print('📦 AuthRepository: Sign in failed');
        print('📦 AuthRepository: Error: $error');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> signInUsingGoogle({required String token}) {
    return remoteDataSource.signInWithGoogle(token: token);
  }
}
