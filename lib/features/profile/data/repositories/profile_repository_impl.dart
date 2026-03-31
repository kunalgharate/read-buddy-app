import '../../../auth/domain/entities/app_user.dart';
import 'package:injectable/injectable.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileUser> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<ProfileUser> updateAvatar(String avatarName) async {
    return await remoteDataSource.updateAvatar(avatarName);
  }

  @override
  Future<AppUser> updateProfile({required Map<String, String> profileData}) async {
    return await remoteDataSource.updateProfile(profileData: profileData);
  }
}