import '../../domain/entities/library_inventory_entity.dart';
import '../../domain/repositories/library_inventory_repository.dart';
import '../datasources/library_inventory_remote_datasource.dart';

class LibraryInventoryRepositoryImpl implements LibraryInventoryRepository {
  final LibraryInventoryRemoteDataSource _remoteDataSource;

  LibraryInventoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<LibraryInventoryEntity> addBookToLibrary({
    required String libraryId,
    required String bookId,
    required String variantId,
    required String formatType,
    required int totalCopies,
  }) =>
      _remoteDataSource.addBookToLibrary(
        libraryId: libraryId,
        bookId: bookId,
        variantId: variantId,
        formatType: formatType,
        totalCopies: totalCopies,
      );

  @override
  Future<List<LibraryInventoryEntity>> getLibraryInventory({
    required String libraryId,
    String? search,
    int? page,
    int? limit,
  }) =>
      _remoteDataSource.getLibraryInventory(
        libraryId: libraryId,
        search: search,
        page: page,
        limit: limit,
      );

  @override
  Future<LibraryInventoryEntity> updateInventory({
    required String id,
    required int totalCopies,
  }) =>
      _remoteDataSource.updateInventory(id: id, totalCopies: totalCopies);

  @override
  Future<void> deleteInventory(String id) =>
      _remoteDataSource.deleteInventory(id);

  @override
  Future<List<CityBookEntity>> browseByCity({
    required String city,
    String? search,
    int? page,
    int? limit,
  }) =>
      _remoteDataSource.browseByCity(
        city: city,
        search: search,
        page: page,
        limit: limit,
      );
}
