import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;
  ChangePasswordUseCase(this._repository);

  Future<void> call(String email, String code, String newPassword) =>
      _repository.changePassword(email, code, newPassword);
}
