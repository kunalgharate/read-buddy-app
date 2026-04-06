import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyResetOtpUseCase {
  final AuthRepository _repository;
  VerifyResetOtpUseCase(this._repository);

  Future<void> call(String email, String otp) =>
      _repository.verifyResetOtp(email, otp);
}
