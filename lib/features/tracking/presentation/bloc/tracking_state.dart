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
