import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class ResendRegisterOtpUseCase {
  final AuthRepository _repository;
  ResendRegisterOtpUseCase(this._repository);

  Future<void> call(String email) => _repository.resendRegisterOtp(email);
}