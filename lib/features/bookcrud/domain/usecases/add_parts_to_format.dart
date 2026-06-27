import 'dart:io';

import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class AddPartsToFormatUsecase {
  final VariantRepository _repository;

  AddPartsToFormatUsecase(this._repository);

  Future<BookVariantEntity> call(
    String variantId,
    String formatId, {
    List<MediaPartEntity> parts = const [],
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
    String? donorId,
    int? copiesDonated,
  }) {
    return _repository.addPartsToFormat(
      variantId,
      formatId,
      parts: parts,
      ebookFiles: ebookFiles,
      audioParts: audioParts,
      videoParts: videoParts,
      donorId: donorId,
      copiesDonated: copiesDonated,
    );
  }
}
