import 'package:read_buddy_app/features/bookcrud/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUserList();
}
