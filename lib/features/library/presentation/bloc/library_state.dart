part of 'library_bloc.dart';

sealed class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object?> get props => [];
}

final class LibraryInitial extends LibraryState {}

final class LibraryLoading extends LibraryState {}

final class LibrariesLoaded extends LibraryState {
  final List<LibraryEntity> libraries;
  const LibrariesLoaded(this.libraries);
  @override
  List<Object?> get props => [libraries];
}

final class SuperLibrariesLoaded extends LibraryState {
  final List<LibraryEntity> libraries;
  const SuperLibrariesLoaded(this.libraries);
  @override
  List<Object?> get props => [libraries];
}

final class LibraryCreated extends LibraryState {
  final LibraryEntity library;
  const LibraryCreated(this.library);
  @override
  List<Object?> get props => [library];
}

final class LibraryUpdated extends LibraryState {
  final LibraryEntity library;
  const LibraryUpdated(this.library);
  @override
  List<Object?> get props => [library];
}

final class LibraryDeleted extends LibraryState {}

final class LibrarianAssigned extends LibraryState {}

final class LibrarianUnassigned extends LibraryState {}

final class LibrariansLoaded extends LibraryState {
  final List<Map<String, dynamic>> librarians;
  const LibrariansLoaded(this.librarians);
  @override
  List<Object?> get props => [librarians];
}

final class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
