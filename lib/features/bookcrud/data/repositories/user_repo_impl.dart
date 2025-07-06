// data/repositories/user_repository_impl.dart
import 'package:read_buddy_app/features/bookcrud/data/dataresources/user_remote_resources.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/user_repo.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteResources remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserEntity>> getUserList() async {
    return await remoteDataSource.getusersList();
  }
}
