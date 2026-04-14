import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateAvatarUseCase {
  final ProfileRepository repository;
  UpdateAvatarUseCase(this.repository);

  Future<ProfileUser> call(String avatarName) =>
      repository.updateAvatar(avatarName);
}
