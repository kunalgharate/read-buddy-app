import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class AddBookUsecase {
  final BookCrudRepository repository;

  AddBookUsecase(this.repository);

  Future<void> call(BookCrudEntity book) => repository.addBook(book);
}
