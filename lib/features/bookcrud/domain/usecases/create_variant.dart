import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class CreateVariantUsecase {
  final VariantRepository _repository;

  CreateVariantUsecase(this._repository);

  Future<BookVariantEntity> call(BookVariantEntity variant) {
    return _repository.createVariant(variant);
  }
}
