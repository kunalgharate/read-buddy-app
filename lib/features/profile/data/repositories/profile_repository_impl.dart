import 'package:injectable/injectable.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../remotesource/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);
  @override
  Future<AppUser> updateProfile(
      {required Map<String, String> profileData}) async {
    return await remoteDataSource.updateProfile(profileData: profileData);
  }
}
