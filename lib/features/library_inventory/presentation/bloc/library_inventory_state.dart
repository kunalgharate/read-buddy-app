part of 'library_inventory_bloc.dart';

sealed class LibraryInventoryState extends Equatable {
  const LibraryInventoryState();
  @override
  List<Object?> get props => [];
}

final class LibraryInventoryInitial extends LibraryInventoryState {}

final class LibraryInventoryLoading extends LibraryInventoryState {}

/// Admin: inventory list for a library loaded.
final class LibraryInventoryLoaded extends LibraryInventoryState {
  final List<LibraryInventoryEntity> inventory;
  const LibraryInventoryLoaded(this.inventory);
  @override
  List<Object?> get props => [inventory];
}

/// Admin: book added to library successfully.
final class InventoryAdded extends LibraryInventoryState {
  final LibraryInventoryEntity inventory;
  const InventoryAdded(this.inventory);
  @override
  List<Object?> get props => [inventory];
}

/// Admin: inventory updated.
final class InventoryUpdated extends LibraryInventoryState {}

/// Admin: inventory deleted.
final class InventoryDeleted extends LibraryInventoryState {}

/// User: city books loaded.
final class CityBooksLoaded extends LibraryInventoryState {
  final List<CityBookEntity> books;
  const CityBooksLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

final class LibraryInventoryError extends LibraryInventoryState {
  final String message;
  const LibraryInventoryError(this.message);
  @override
  List<Object?> get props => [message];
}
