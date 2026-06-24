import 'dart:io';

import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class AddFormatUsecase {
  final VariantRepository _repository;

  AddFormatUsecase(this._repository);

  Future<BookVariantEntity> call(
    String variantId,
    List<BookFormatEntity> formats, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) {
    return _repository.addFormatsToVariant(
      variantId,
      formats,
      ebookFiles: ebookFiles,
      audioParts: audioParts,
      videoParts: videoParts,
    );
  }
}
