import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/bookcrud/domain/respository/bookcrud_repo.dart';

@injectable
class DeleteBookusecase {
  final BookCrudRepository repository;

  DeleteBookusecase(this.repository);

  Future<void> call(String id) => repository.deleteBook(id);
}
