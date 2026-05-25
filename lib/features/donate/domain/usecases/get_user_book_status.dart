import 'package:read_buddy_app/features/donate/domain/entities/user_book_status.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';

class GetUserBookStatus {
  final DonateRepository repository;

  GetUserBookStatus(this.repository);

  Future<UserBookStatus> call() async {
    return await repository.getUserBookStatus();
  }
}
