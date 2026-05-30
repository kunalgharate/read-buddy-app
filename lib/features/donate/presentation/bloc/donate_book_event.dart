part of 'donate_book_bloc.dart';

sealed class DonateBookEvent extends Equatable {
  const DonateBookEvent();

  @override
  List<Object> get props => [];
}

final class LoadDonationStats extends DonateBookEvent {}

final class LoadNearestAgents extends DonateBookEvent {}

final class SubmitBookDonationEvent extends DonateBookEvent {
  final BookDonationRequest request;

  const SubmitBookDonationEvent(this.request);

  @override
  List<Object> get props => [request];
}

final class UploadDonationReceiptEvent extends DonateBookEvent {
  final String donationId;
  final FormData formData;

  const UploadDonationReceiptEvent({required this.donationId, required this.formData});

  @override
  List<Object> get props => [donationId, formData];
}