import '../repositories/book_request_repository.dart';

class CreateBookRequestUsecase {
  final BookRequestRepository repository;

  CreateBookRequestUsecase(this.repository);

  Future<void> call(String bookId) => repository.createBookRequest(bookId);
}
