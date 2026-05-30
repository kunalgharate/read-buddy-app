import '../repositories/book_request_repository.dart';

class UpdateRequestStatusUsecase {
  final BookRequestRepository repository;

  UpdateRequestStatusUsecase(this.repository);

  Future<void> call(String id, String status) =>
      repository.updateRequestStatus(id, status);
}
