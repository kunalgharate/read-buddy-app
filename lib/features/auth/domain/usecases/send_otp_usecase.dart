import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase {
  final AuthRepository _repository;
  SendOtpUseCase(this._repository);

  Future<void> call(String email) => _repository.sendOtp(email);
}
