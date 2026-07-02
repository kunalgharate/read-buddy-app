part of 'library_bloc.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object?> get props => [];
}

final class LoadLibraries extends LibraryEvent {
  final String? city;
  const LoadLibraries({this.city});
  @override
  List<Object?> get props => [city];
}

final class LoadSuperLibraries extends LibraryEvent {}

final class LoadLibraryDetails extends LibraryEvent {}

final class CreateLibraryEvent extends LibraryEvent {
  final Map<String, dynamic> data;
  const CreateLibraryEvent(this.data);
  @override
  List<Object?> get props => [data];
}

final class UpdateLibraryEvent extends LibraryEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateLibraryEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

final class DeleteLibraryEvent extends LibraryEvent {
  final String id;
  const DeleteLibraryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

final class ToggleSuperLibraryEvent extends LibraryEvent {
  final String id;
  const ToggleSuperLibraryEvent(this.id);
  @override
  List<Object?> get props => [id];
}

final class AssignLibrarianEvent extends LibraryEvent {
  final String userId;
  final String libraryId;
  const AssignLibrarianEvent(this.userId, this.libraryId);
  @override
  List<Object?> get props => [userId, libraryId];
}

final class UnassignLibrarianEvent extends LibraryEvent {
  final String userId;
  const UnassignLibrarianEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

final class LoadLibrariansEvent extends LibraryEvent {}
