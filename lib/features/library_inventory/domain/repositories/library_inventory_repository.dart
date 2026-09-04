import '../entities/library_inventory_entity.dart';

abstract class LibraryInventoryRepository {
  Future<LibraryInventoryEntity> addBookToLibrary({
    required String libraryId,
    required String bookId,
    required String variantId,
    required String formatType,
    required int totalCopies,
  });

  Future<List<LibraryInventoryEntity>> getLibraryInventory({
    required String libraryId,
    String? search,
    int? page,
    int? limit,
  });

  Future<LibraryInventoryEntity> updateInventory({
    required String id,
    required int totalCopies,
  });

  Future<void> deleteInventory(String id);

  Future<List<CityBookEntity>> browseByCity({
    required String city,
    String? search,
    int? page,
    int? limit,
  });
}
