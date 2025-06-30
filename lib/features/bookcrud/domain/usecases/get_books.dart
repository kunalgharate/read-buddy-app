// Get all books
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class GetBooksUsecase {
  final BookCrudRepository repository;

  GetBooksUsecase(this.repository);

  Future<List<BookCrudEntity>> call() => repository.getBooks();
}
