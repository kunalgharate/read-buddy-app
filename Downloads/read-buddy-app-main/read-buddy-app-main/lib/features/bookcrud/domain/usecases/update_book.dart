import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class UpdateBookUsecase {
  final BookCrudRepository repository;

  UpdateBookUsecase(this.repository);

  Future<void> call(String id, BookCrudEntity book) =>
      repository.updateBook(id, book);
}
