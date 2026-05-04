import '../repositories/book_request_repository.dart';

class DeclineBookRequestUsecase {
  final BookRequestRepository repository;

  DeclineBookRequestUsecase(this.repository);

  Future<void> call(String id, {String reason = 'Request declined'}) =>
      repository.declineBookRequest(id, reason: reason);
}
