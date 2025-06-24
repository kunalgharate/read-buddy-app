import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class GetBookByIdUsecase {
  final BookCrudRepository repository;

  GetBookByIdUsecase(this.repository);

  Future<BookCrudEntity> call(String id) => repository.getBookById(id);
}
