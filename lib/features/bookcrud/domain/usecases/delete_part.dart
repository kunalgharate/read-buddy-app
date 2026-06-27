import '../respository/variant_repository.dart';

class DeletePartUsecase {
  final VariantRepository _repository;

  DeletePartUsecase(this._repository);

  Future<void> call(String variantId, String formatId, int partNumber) {
    return _repository.deletePartFromFormat(variantId, formatId, partNumber);
  }
}
