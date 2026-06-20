import 'package:injectable/injectable.dart';
import '../../domain/entities/parent_book_entity.dart';
import '../../domain/entities/book_variant_entity.dart';
import '../../domain/respository/variant_repository.dart';
import '../model/book_variant_model.dart';
import '../dataresources/variant_remote_data_source.dart';

/// VariantRepositoryImpl — routes all Book Variant operations to the live backend
/// via [VariantRemoteDataSource] (Dio).
///
/// SharedPreferences has been removed entirely:
///  - Parent book creation is handled by [BookCrudBloc] → AddBookCrudEvent.
///  - Variant CRUD is persisted on the server (readbuddy-server / BookVariantRoutes.js).
@LazySingleton(as: VariantRepository)
class VariantRepositoryImpl implements VariantRepository {
  final VariantRemoteDataSource remoteDataSource;

  VariantRepositoryImpl(this.remoteDataSource);

  /// Parent books are managed by the BookCrudBloc / books API.
  /// This method is a no-op — no local storage is used.
  @override
  Future<List<ParentBookEntity>> getParentBooks() async => [];

  /// Parent book persistence is delegated to BookCrudBloc → AddBookCrudEvent.
  /// This method is a no-op — no local storage is used.
  @override
  Future<void> saveParentBook(ParentBookEntity book) async {
    // intentionally empty — parent book is saved via the /api/books endpoint
    // through BookCrudBloc, not through the variant repository.
  }

  /// Fetches all active variants for [bookId] from the backend.
  /// Backend: GET /api/book-variants/:bookId → raw JSON array.
  @override
  Future<List<BookVariantEntity>> getVariantsForBook(String bookId) async {
    return await remoteDataSource.getVariantsForBook(bookId);
  }

  /// Creates or updates a variant on the backend.
  ///
  /// Decision rule:
  ///  - If [variant.id] is empty or starts with 'var_' (a local temp ID generated
  ///    in the UI before the server assigns a real _id), call POST (create).
  ///  - Otherwise, the variant has a real MongoDB _id → call PUT (update).
  @override
  Future<void> saveVariant(BookVariantEntity variant) async {
    final model = BookVariantModel.fromEntity(variant);
    final isNew = variant.id.isEmpty || variant.id.startsWith('var_');
    if (isNew) {
      await remoteDataSource.createVariant(model);
    } else {
      await remoteDataSource.updateVariant(variant.id, model);
    }
  }

  /// Soft-deletes a variant by ID on the backend.
  /// Backend: DELETE /api/book-variants/:id → { message: '...' }
  @override
  Future<void> deleteVariant(String variantId) async {
    await remoteDataSource.deleteVariant(variantId);
  }
}
