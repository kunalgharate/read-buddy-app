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
  Future<BookVariantEntity> addFormatsToVariant(
    String variantId,
    List<BookFormatEntity> formats, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) async {
    // The backend auto-merges new format types when POST /book-variants is
    // called with an existing bookId+language. We fetch the existing variant
    // to get bookId and language, then call createVariant which triggers the
    // server-side merge logic.
    final existing = await remoteDataSource.getVariantById(variantId);
    final model = BookVariantModel(
      id: '',
      bookId: existing.bookId,
      language: existing.language,
      donorId: existing.donorId,
      formats: formats,
    );
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
    // No PATCH endpoint exists on the backend. For now, fetch and return
    // the current state. Actual updates are done via addPartsToFormat or
    // addFormatsToVariant.
    return await remoteDataSource.getVariantById(variantId);
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    await remoteDataSource.deleteVariant(variantId);
  }

  @override
  Future<void> removeFormatFromVariant(
      String variantId, String formatId) async {
    await remoteDataSource.removeFormatFromVariant(variantId, formatId);
  }

  @override
  Future<BookVariantEntity> addPartsToFormat(
    String variantId,
    String formatId, {
    List<MediaPartEntity> parts = const [],
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
    String? donorId,
    int? copiesDonated,
  }) async {
    return await remoteDataSource.addPartsToFormat(
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

  @override
  Future<void> deletePartFromFormat(
    String variantId,
    String formatId,
    int partNumber,
  ) async {
    await remoteDataSource.deletePartFromFormat(
        variantId, formatId, partNumber);
  }
}
