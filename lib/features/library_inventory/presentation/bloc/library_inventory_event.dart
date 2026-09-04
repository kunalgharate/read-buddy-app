part of 'library_inventory_bloc.dart';

sealed class LibraryInventoryEvent extends Equatable {
  const LibraryInventoryEvent();
  @override
  List<Object?> get props => [];
}

/// Admin: Load all inventory for a specific library.
final class LoadLibraryInventory extends LibraryInventoryEvent {
  final String libraryId;
  final String? search;
  const LoadLibraryInventory({required this.libraryId, this.search});
  @override
  List<Object?> get props => [libraryId, search];
}

/// Admin: Add a book to a library.
final class AddBookToLibraryEvent extends LibraryInventoryEvent {
  final String libraryId;
  final String bookId;
  final String variantId;
  final String formatType;
  final int totalCopies;

  const AddBookToLibraryEvent({
    required this.libraryId,
    required this.bookId,
    required this.variantId,
    required this.formatType,
    required this.totalCopies,
  });

  @override
  List<Object?> get props =>
      [libraryId, bookId, variantId, formatType, totalCopies];
}

/// Admin: Update copy count.
final class UpdateInventoryEvent extends LibraryInventoryEvent {
  final String id;
  final int totalCopies;
  final String libraryId; // to reload list after update

  const UpdateInventoryEvent({
    required this.id,
    required this.totalCopies,
    required this.libraryId,
  });

  @override
  List<Object?> get props => [id, totalCopies, libraryId];
}

/// Admin: Remove a book from library inventory.
final class DeleteInventoryEvent extends LibraryInventoryEvent {
  final String id;
  final String libraryId; // to reload list after delete

  const DeleteInventoryEvent({required this.id, required this.libraryId});

  @override
  List<Object?> get props => [id, libraryId];
}

/// User: Browse books in a city.
final class BrowseCityBooks extends LibraryInventoryEvent {
  final String city;
  final String? search;
  const BrowseCityBooks({required this.city, this.search});
  @override
  List<Object?> get props => [city, search];
}
