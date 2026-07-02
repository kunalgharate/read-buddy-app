part of 'donate_book_bloc.dart';

sealed class DonateBookState extends Equatable {
  const DonateBookState();

  @override
  List<Object> get props => [];
}

final class DonateBookInitial extends DonateBookState {}

final class DonateBookLoading extends DonateBookState {}

final class DonationStatsLoaded extends DonateBookState {
  final DonationStats stats;

  const DonationStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

final class NearestLibrariesLoaded extends DonateBookState {
  final List<LibraryEntity> libraries;

  const NearestLibrariesLoaded(this.libraries);

  @override
  List<Object> get props => [libraries];
}

final class BookDonationCreated extends DonateBookState {}

final class ReceiptUploaded extends DonateBookState {}

final class DonateBookError extends DonateBookState {
  final String message;

  const DonateBookError(this.message);

  @override
  List<Object> get props => [message];
}
