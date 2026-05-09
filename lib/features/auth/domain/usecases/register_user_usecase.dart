import 'package:injectable/injectable.dart';

import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

/// SignIn use case
@injectable
class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<AppUser> call(Map<String, dynamic> data) =>
      repository.registerUser(data);
}
