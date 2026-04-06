import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepository _repository;
  ChangePasswordUseCase(this._repository);

  Future<void> call(String email, String code, String newPassword) =>
      _repository.changePassword(email, code, newPassword);
}
