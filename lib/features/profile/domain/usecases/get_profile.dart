import 'package:injectable/injectable.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);

  Future<ProfileUser> call() => _repository.getProfile();
}