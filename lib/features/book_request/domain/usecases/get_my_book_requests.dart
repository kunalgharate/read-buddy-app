import '../entities/book_request_entity.dart';
import '../repositories/book_request_repository.dart';

class GetMyBookRequestsUsecase {
  final BookRequestRepository repository;

  GetMyBookRequestsUsecase(this.repository);

  Future<List<BookRequestEntity>> call() => repository.getMyBookRequests();
}
