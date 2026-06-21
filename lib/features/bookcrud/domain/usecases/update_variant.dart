import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class UpdateVariantUsecase {
  final VariantRepository _repository;

  UpdateVariantUsecase(this._repository);

  Future<BookVariantEntity> call(String variantId, Map<String, dynamic> data) {
    return _repository.updateVariant(variantId, data);
  }
}
