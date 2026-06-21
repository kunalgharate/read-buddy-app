import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class GetVariantsForBookUsecase {
  final VariantRepository _repository;

  GetVariantsForBookUsecase(this._repository);

  Future<List<BookVariantEntity>> call(String bookId) {
    return _repository.getVariantsForBook(bookId);
  }
}
