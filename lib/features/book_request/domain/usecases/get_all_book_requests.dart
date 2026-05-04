import '../entities/book_request_entity.dart';
import '../repositories/book_request_repository.dart';

class GetAllBookRequestsUsecase {
  final BookRequestRepository repository;

  GetAllBookRequestsUsecase(this.repository);

  Future<List<BookRequestEntity>> call() => repository.getAllBookRequests();
}
