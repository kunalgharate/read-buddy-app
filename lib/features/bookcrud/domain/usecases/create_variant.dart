import 'dart:io';

import '../entities/book_variant_entity.dart';
import '../respository/variant_repository.dart';

class CreateVariantUsecase {
  final VariantRepository _repository;

  CreateVariantUsecase(this._repository);

  Future<BookVariantEntity> call(
    BookVariantEntity variant, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) {
    return _repository.createVariant(
      variant,
      ebookFiles: ebookFiles,
      audioParts: audioParts,
      videoParts: videoParts,
    );
  }
}
