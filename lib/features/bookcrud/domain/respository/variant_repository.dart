import '../entities/book_variant_entity.dart';

abstract class VariantRepository {
  /// Fetches all variants for a given book ID.
  /// GET /api/book-variants/book/:bookId
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId);

  /// Fetches a single variant by ID.
  /// GET /api/book-variants/:variantId
  Future<BookVariantEntity> getVariantById(String variantId);

  /// Creates a new variant with formats.
  /// POST /api/book-variants
  Future<BookVariantEntity> createVariant(BookVariantEntity variant);

  /// Updates variant-level fields (language, etc.).
  /// PUT /api/book-variants/:variantId
  Future<BookVariantEntity> updateVariant(
      String variantId, Map<String, dynamic> data);

  /// Deletes an entire variant.
  /// DELETE /api/book-variants/:variantId
  Future<void> deleteVariant(String variantId);

  /// Adds one or more formats to an existing variant.
  /// POST /api/book-variants/:variantId/formats
  Future<BookVariantEntity> addFormatsToVariant(
      String variantId, List<BookFormatEntity> formats);

  /// Removes a single format from a variant.
  /// DELETE /api/book-variants/:variantId/formats/:formatId
  Future<void> removeFormatFromVariant(String variantId, String formatId);
}
