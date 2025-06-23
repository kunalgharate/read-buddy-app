import 'package:dartz/dartz.dart';
import 'package:read_buddy_app/core/error/failure.dart';

import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<dynamic> signInUsingGoogle();
  Future<dynamic> signUp();
  Future<dynamic> forgetPassword();
  Future<Either<Failure, AppUser>> signInWithGoogle(String idToken);
}
