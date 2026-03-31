import '../repositories/auth_repository.dart';

class VerifyResetOtpUseCase {
  final AuthRepository _repository;
  VerifyResetOtpUseCase(this._repository);

  Future<void> call(String email, String otp) =>
      _repository.verifyResetOtp(email, otp);
}