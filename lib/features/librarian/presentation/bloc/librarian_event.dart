part of 'librarian_bloc.dart';

sealed class LibrarianEvent extends Equatable {
  const LibrarianEvent();
  @override
  List<Object?> get props => [];
}

final class LoadLibrarianDashboard extends LibrarianEvent {}

final class LoadLibrarianRequests extends LibrarianEvent {}

final class AcceptRequestEvent extends LibrarianEvent {
  final String requestId;
  const AcceptRequestEvent(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

final class RejectRequestEvent extends LibrarianEvent {
  final String requestId;
  final String reason;
  const RejectRequestEvent(this.requestId, this.reason);
  @override
  List<Object?> get props => [requestId, reason];
}

final class UpdateRequestStatusEvent extends LibrarianEvent {
  final String requestId;
  final String status;
  const UpdateRequestStatusEvent(this.requestId, this.status);
  @override
  List<Object?> get props => [requestId, status];
}

final class LoadLibrarianDonations extends LibrarianEvent {}

final class UpdateDonationStatusEvent extends LibrarianEvent {
  final String donationId;
  final String status;
  const UpdateDonationStatusEvent(this.donationId, this.status);
  @override
  List<Object?> get props => [donationId, status];
}

final class SchedulePickupEvent extends LibrarianEvent {
  final String donationId;
  final Map<String, dynamic> data;
  const SchedulePickupEvent(this.donationId, this.data);
  @override
  List<Object?> get props => [donationId, data];
}
