import '../../../auth/domain/entities/app_user.dart';

abstract class ProfileRepository {
  Future<AppUser> updateProfile({
    required Map<String, String> profileData,
  });
}
