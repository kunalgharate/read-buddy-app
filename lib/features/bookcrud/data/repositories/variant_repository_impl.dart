import 'dart:io';

import '../../domain/entities/book_variant_entity.dart';
import '../../domain/respository/variant_repository.dart';
import '../model/book_variant_model.dart';
import '../dataresources/variant_remote_data_source.dart';

class VariantRepositoryImpl implements VariantRepository {
  final VariantRemoteDataSource remoteDataSource;

  VariantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId) async {
    return await remoteDataSource.getVariantsForBook(bookId);
  }

  @override
  Future<BookVariantEntity> getVariantById(String variantId) async {
    return await remoteDataSource.getVariantById(variantId);
  }

  @override
  Future<BookVariantEntity> createVariant(
    BookVariantEntity variant, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) async {
    final model = BookVariantModel.fromEntity(variant);
    return await remoteDataSource.createVariant(
      model,
      ebookFiles: ebookFiles,
      audioParts: audioParts,
      videoParts: videoParts,
    );
  }

  @override
  Future<BookVariantEntity> updateVariant(
      String variantId, Map<String, dynamic> data) async {
    return await remoteDataSource.updateVariant(variantId, data);
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    await remoteDataSource.deleteVariant(variantId);
  }

  @override
  Future<BookVariantEntity> addFormatsToVariant(
    String variantId,
    List<BookFormatEntity> formats, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) async {
    final formatModels =
        formats.map((f) => BookFormatModel.fromEntity(f)).toList();
    return await remoteDataSource.addFormatsToVariant(
      variantId,
      formatModels,
      ebookFiles: ebookFiles,
      audioParts: audioParts,
      videoParts: videoParts,
    );
  }

  @override
  Future<void> removeFormatFromVariant(
      String variantId, String formatId) async {
    await remoteDataSource.removeFormatFromVariant(variantId, formatId);
  }
}
