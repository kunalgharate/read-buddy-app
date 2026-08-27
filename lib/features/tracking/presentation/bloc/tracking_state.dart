part of 'tracking_bloc.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();
  @override
  List<Object?> get props => [];
}

final class TrackingInitial extends TrackingState {}

final class TrackingLoading extends TrackingState {}

final class TrackingLoaded extends TrackingState {
  final ShipmentEntity shipment;
  const TrackingLoaded(this.shipment);
  @override
  List<Object?> get props => [shipment];
}

final class TrackingError extends TrackingState {
  final String message;
  const TrackingError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Emitted when a refresh fails but we still have the previously loaded
/// shipment to display. Carries both so the UI can show a transient error
/// (e.g. snackbar) without losing the visible data.
final class TrackingRefreshError extends TrackingState {
  final ShipmentEntity shipment;
  final String message;
  const TrackingRefreshError(this.shipment, this.message);
  @override
  List<Object?> get props => [shipment, message];
}
