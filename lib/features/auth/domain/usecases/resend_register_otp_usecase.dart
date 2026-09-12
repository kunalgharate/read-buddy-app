import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Resends the registration verification OTP for an unverified account,
/// requiring only the email (used for login-originated verification).
@injectable
class ResendRegisterOtpUseCase {
  final AuthRepository repository;

  ResendRegisterOtpUseCase(this.repository);

  Future<void> call(String email) => repository.resendRegisterOtp(email);
}
