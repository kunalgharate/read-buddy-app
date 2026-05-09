import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// GET /users/profile
  Future<ProfileUser> getProfile();

  /// PATCH /users/update-avatar
  Future<ProfileUser> updateAvatar(String avatarName);

  /// PUT /users/update-user-info
  Future<AppUser> updateProfile({required Map<String, String> profileData});
}
