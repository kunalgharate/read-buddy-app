import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/library_inventory_entity.dart';
import '../../domain/repositories/library_inventory_repository.dart';

part 'library_inventory_event.dart';
part 'library_inventory_state.dart';

class LibraryInventoryBloc
    extends Bloc<LibraryInventoryEvent, LibraryInventoryState> {
  final LibraryInventoryRepository _repository;

  LibraryInventoryBloc({required LibraryInventoryRepository repository})
      : _repository = repository,
        super(LibraryInventoryInitial()) {
    on<LoadLibraryInventory>(_onLoadInventory);
    on<AddBookToLibraryEvent>(_onAddBook);
    on<UpdateInventoryEvent>(_onUpdateInventory);
    on<DeleteInventoryEvent>(_onDeleteInventory);
    on<BrowseCityBooks>(_onBrowseCity);
  }

  Future<void> _onLoadInventory(
    LoadLibraryInventory event,
    Emitter<LibraryInventoryState> emit,
  ) async {
    emit(LibraryInventoryLoading());
    try {
      final inventory = await _repository.getLibraryInventory(
        libraryId: event.libraryId,
        search: event.search,
      );
      emit(LibraryInventoryLoaded(inventory));
    } catch (e) {
      emit(LibraryInventoryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAddBook(
    AddBookToLibraryEvent event,
    Emitter<LibraryInventoryState> emit,
  ) async {
    emit(LibraryInventoryLoading());
    try {
      final result = await _repository.addBookToLibrary(
        libraryId: event.libraryId,
        bookId: event.bookId,
        variantId: event.variantId,
        formatType: event.formatType,
        totalCopies: event.totalCopies,
      );
      emit(InventoryAdded(result));
    } catch (e) {
      emit(LibraryInventoryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateInventory(
    UpdateInventoryEvent event,
    Emitter<LibraryInventoryState> emit,
  ) async {
    emit(LibraryInventoryLoading());
    try {
      await _repository.updateInventory(
        id: event.id,
        totalCopies: event.totalCopies,
      );
      emit(InventoryUpdated());
      // Reload the inventory list
      final inventory = await _repository.getLibraryInventory(
        libraryId: event.libraryId,
      );
      emit(LibraryInventoryLoaded(inventory));
    } catch (e) {
      emit(LibraryInventoryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteInventory(
    DeleteInventoryEvent event,
    Emitter<LibraryInventoryState> emit,
  ) async {
    emit(LibraryInventoryLoading());
    try {
      await _repository.deleteInventory(event.id);
      emit(InventoryDeleted());
      // Reload the inventory list
      final inventory = await _repository.getLibraryInventory(
        libraryId: event.libraryId,
      );
      emit(LibraryInventoryLoaded(inventory));
    } catch (e) {
      emit(LibraryInventoryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onBrowseCity(
    BrowseCityBooks event,
    Emitter<LibraryInventoryState> emit,
  ) async {
    emit(LibraryInventoryLoading());
    try {
      final books = await _repository.browseByCity(
        city: event.city,
        search: event.search,
      );
      emit(CityBooksLoaded(books));
    } catch (e) {
      emit(LibraryInventoryError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
