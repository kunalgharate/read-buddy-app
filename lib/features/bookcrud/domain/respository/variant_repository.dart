import '../entities/parent_book_entity.dart';
import '../entities/book_variant_entity.dart';

abstract class VariantRepository {
  /// Fetches all parent books.
  Future<List<ParentBookEntity>> getParentBooks();

  /// Saves a parent book.
  Future<void> saveParentBook(ParentBookEntity book);

  /// Fetches variants for a given parent book ID.
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId);

  /// Saves a language variant.
  Future<void> saveVariant(BookVariantEntity variant);

  /// Deletes a language variant by ID.
  Future<void> deleteVariant(String variantId);
}
