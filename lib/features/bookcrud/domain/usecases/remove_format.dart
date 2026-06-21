import '../respository/variant_repository.dart';

class RemoveFormatUsecase {
  final VariantRepository _repository;

  RemoveFormatUsecase(this._repository);

  Future<void> call(String variantId, String formatId) {
    return _repository.removeFormatFromVariant(variantId, formatId);
  }
}
