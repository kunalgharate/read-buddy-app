import '../repositories/book_request_repository.dart';

class AcceptBookRequestUsecase {
  final BookRequestRepository repository;

  AcceptBookRequestUsecase(this.repository);

  Future<void> call(String id, {String? notes}) =>
      repository.acceptBookRequest(id, notes: notes);
}
