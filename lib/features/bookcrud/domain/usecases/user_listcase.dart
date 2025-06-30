import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/user_repo.dart';

class GetUserListUseCase {
  final UserRepository repository;

  GetUserListUseCase(this.repository);

  Future<List<UserEntity>> call() {
    return repository.getUserList();
  }
}
