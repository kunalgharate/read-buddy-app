import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/profile/domain/entities/user_profile.dart';
import 'package:read_buddy_app/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);

  Future<ProfileUser> call() => _repository.getProfile();
}
