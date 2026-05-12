import 'package:injectable/injectable.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<AppUser> call({
    required Map<String, String> profileData,
  }) async {
    return await repository.updateProfile(profileData: profileData);
  }
}
