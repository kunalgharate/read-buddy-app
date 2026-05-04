import '../entities/book_detail_entity.dart';
import '../repositories/book_request_repository.dart';

class GetBookDetailUsecase {
  final BookRequestRepository repository;

  GetBookDetailUsecase(this.repository);

  Future<BookDetailEntity> call(String id) => repository.getBookById(id);
}
