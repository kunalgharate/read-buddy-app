import 'dart:io';

import '../entities/book_variant_entity.dart';

abstract class VariantRepository {
  /// Fetches all variants for a given book ID.
  /// GET /api/book-variants/book/:bookId
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId);

  /// Fetches a single variant by ID.
  /// GET /api/book-variants/:variantId
  Future<BookVariantEntity> getVariantById(String variantId);

  /// Creates a new variant with formats and file uploads.
  /// If bookId+language already exists, server auto-merges formats.
  /// POST /api/book-variants (multipart form data)
  Future<BookVariantEntity> createVariant(
    BookVariantEntity variant, {
    List<File> ebookFiles,
    List<File> audioParts,
    List<File> videoParts,
  });

  /// Adds new format types to an existing variant.
  /// Uses the same POST /api/book-variants endpoint — server auto-merges
  /// if bookId+language already exists.
  Future<BookVariantEntity> addFormatsToVariant(
    String variantId,
    List<BookFormatEntity> formats, {
    List<File> ebookFiles,
    List<File> audioParts,
    List<File> videoParts,
  });

  /// Updates a variant (re-submits formats via create/merge).
  /// The backend has no PATCH — this uses POST which auto-merges.
  Future<BookVariantEntity> updateVariant(
      String variantId, Map<String, dynamic> data);

  /// Deletes an entire variant.
  /// DELETE /api/book-variants/:variantId
  Future<void> deleteVariant(String variantId);

  /// Removes a single format from a variant.
  /// Auto-deletes variant if no formats remain.
  /// DELETE /api/book-variants/:variantId/formats/:formatId
  Future<void> removeFormatFromVariant(String variantId, String formatId);

  /// Adds parts/files to an existing format (incremental).
  /// POST /api/book-variants/:variantId/formats/:formatId/parts
  Future<BookVariantEntity> addPartsToFormat(
    String variantId,
    String formatId, {
    List<MediaPartEntity> parts,
    List<File> ebookFiles,
    List<File> audioParts,
    List<File> videoParts,
    String? donorId,
    int? copiesDonated,
  });

  /// Deletes a specific part from a format.
  /// DELETE /api/book-variants/:variantId/formats/:formatId/parts/:partNumber
  Future<void> deletePartFromFormat(
    String variantId,
    String formatId,
    int partNumber,
  );
}
