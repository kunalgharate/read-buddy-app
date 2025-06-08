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


  @override
  Future signInUsingGoogle() {
    // TODO: implement signInUsingGoogle
    throw UnimplementedError();
  }

  @override
  Future signUp() {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return remoteDataSource.signIn(email: email, password: password);
  }
}
