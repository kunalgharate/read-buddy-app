import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/usecases/library_usecases.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetLibraries _getLibraries;
  final GetSuperLibraries _getSuperLibraries;
  final GetLibraryDetails _getLibraryDetails;
  final CreateLibrary _createLibrary;
  final UpdateLibrary _updateLibrary;
  final DeleteLibrary _deleteLibrary;
  final ToggleSuperLibrary _toggleSuperLibrary;
  final AssignLibrarian _assignLibrarian;
  final UnassignLibrarian _unassignLibrarian;
  final GetLibrarians _getLibrarians;

  LibraryBloc({
    required GetLibraries getLibraries,
    required GetSuperLibraries getSuperLibraries,
    required GetLibraryDetails getLibraryDetails,
    required CreateLibrary createLibrary,
    required UpdateLibrary updateLibrary,
    required DeleteLibrary deleteLibrary,
    required ToggleSuperLibrary toggleSuperLibrary,
    required AssignLibrarian assignLibrarian,
    required UnassignLibrarian unassignLibrarian,
    required GetLibrarians getLibrarians,
  })  : _getLibraries = getLibraries,
        _getSuperLibraries = getSuperLibraries,
        _getLibraryDetails = getLibraryDetails,
        _createLibrary = createLibrary,
        _updateLibrary = updateLibrary,
        _deleteLibrary = deleteLibrary,
        _toggleSuperLibrary = toggleSuperLibrary,
        _assignLibrarian = assignLibrarian,
        _unassignLibrarian = unassignLibrarian,
        _getLibrarians = getLibrarians,
        super(LibraryInitial()) {
    on<LoadLibraries>(_onLoadLibraries);
    on<LoadSuperLibraries>(_onLoadSuperLibraries);
    on<LoadLibraryDetails>(_onLoadLibraryDetails);
    on<CreateLibraryEvent>(_onCreateLibrary);
    on<UpdateLibraryEvent>(_onUpdateLibrary);
    on<DeleteLibraryEvent>(_onDeleteLibrary);
    on<ToggleSuperLibraryEvent>(_onToggleSuperLibrary);
    on<AssignLibrarianEvent>(_onAssignLibrarian);
    on<UnassignLibrarianEvent>(_onUnassignLibrarian);
    on<LoadLibrariansEvent>(_onLoadLibrarians);
  }

  Future<void> _onLoadLibraries(
    LoadLibraries event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final libraries = await _getLibraries(city: event.city);
      emit(LibrariesLoaded(libraries));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadSuperLibraries(
    LoadSuperLibraries event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final libraries = await _getSuperLibraries();
      emit(SuperLibrariesLoaded(libraries));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadLibraryDetails(
    LoadLibraryDetails event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final libraries = await _getLibraryDetails();
      emit(LibrariesLoaded(libraries));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCreateLibrary(
    CreateLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final library = await _createLibrary(event.data);
      emit(LibraryCreated(library));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateLibrary(
    UpdateLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final library = await _updateLibrary(event.id, event.data);
      emit(LibraryUpdated(library));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteLibrary(
    DeleteLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      await _deleteLibrary(event.id);
      emit(LibraryDeleted());
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onToggleSuperLibrary(
    ToggleSuperLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final library = await _toggleSuperLibrary(event.id);
      emit(LibraryUpdated(library));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAssignLibrarian(
    AssignLibrarianEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      await _assignLibrarian(event.userId, event.libraryId);
      emit(LibrarianAssigned());
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUnassignLibrarian(
    UnassignLibrarianEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      await _unassignLibrarian(event.userId);
      emit(LibrarianUnassigned());
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadLibrarians(
    LoadLibrariansEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    try {
      final librarians = await _getLibrarians();
      emit(LibrariansLoaded(librarians));
    } catch (e) {
      emit(LibraryError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
