part of 'librarian_bloc.dart';

sealed class LibrarianState extends Equatable {
  const LibrarianState();
  @override
  List<Object?> get props => [];
}

final class LibrarianInitial extends LibrarianState {}

final class LibrarianLoading extends LibrarianState {}

final class LibrarianDashboardLoaded extends LibrarianState {
  final LibraryEntity library;
  final Map<String, dynamic> stats;
  const LibrarianDashboardLoaded({required this.library, required this.stats});
  @override
  List<Object?> get props => [library, stats];
}

final class LibrarianRequestsLoaded extends LibrarianState {
  final List<Map<String, dynamic>> requests;
  const LibrarianRequestsLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

final class LibrarianDonationsLoaded extends LibrarianState {
  final List<Map<String, dynamic>> donations;
  const LibrarianDonationsLoaded(this.donations);
  @override
  List<Object?> get props => [donations];
}

final class LibrarianActionSuccess extends LibrarianState {
  final String message;
  const LibrarianActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

final class LibrarianError extends LibrarianState {
  final String message;
  const LibrarianError(this.message);
  @override
  List<Object?> get props => [message];
}
