import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository _repository;
  SendOtpUseCase(this._repository);

  Future<void> call(String email) => _repository.sendOtp(email);
}
