import '../respository/variant_repository.dart';

class DeleteVariantUsecase {
  final VariantRepository _repository;

  DeleteVariantUsecase(this._repository);

  Future<void> call(String variantId) {
    return _repository.deleteVariant(variantId);
  }
}
