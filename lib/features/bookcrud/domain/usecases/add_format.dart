import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class AddFormatUsecase {
  final VariantRepository _repository;

  AddFormatUsecase(this._repository);

  Future<BookVariantEntity> call(
      String variantId, List<BookFormatEntity> formats) {
    return _repository.addFormatsToVariant(variantId, formats);
  }
}
