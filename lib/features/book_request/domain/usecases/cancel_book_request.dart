import '../repositories/book_request_repository.dart';

class CancelBookRequestUsecase {
  final BookRequestRepository repository;
  CancelBookRequestUsecase(this.repository);

  Future<void> call(String id, String reason) => repository.cancelBookRequest(id, reason);
}
