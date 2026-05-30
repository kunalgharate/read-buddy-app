import '../entities/book_request_entity.dart';
import '../repositories/book_request_repository.dart';

class GetUpcomingPickupsUsecase {
  final BookRequestRepository repository;

  GetUpcomingPickupsUsecase(this.repository);

  Future<List<BookRequestEntity>> call() => repository.getUpcomingPickups();
}
