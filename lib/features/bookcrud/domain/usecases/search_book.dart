// Get all books
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class SearchBookUsecase {
  final BookCrudRepository repository;

  SearchBookUsecase(this.repository);

  Future<List<BookCrudEntity>> call(String query) =>
      repository.searchBooks(query);
}
