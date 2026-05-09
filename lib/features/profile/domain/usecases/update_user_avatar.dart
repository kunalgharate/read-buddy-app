import 'package:read_buddy_app/features/profile/domain/entities/user_profile.dart';
import 'package:read_buddy_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateAvatarUseCase {
  final ProfileRepository repository;
  UpdateAvatarUseCase(this.repository);

  Future<ProfileUser> call(String avatarName) =>
      repository.updateAvatar(avatarName);
}
