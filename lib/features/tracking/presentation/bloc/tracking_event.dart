part of 'tracking_bloc.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();
  @override
  List<Object?> get props => [];
}

final class LoadShipmentByRequest extends TrackingEvent {
  final String requestId;
  const LoadShipmentByRequest(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

final class LoadShipmentById extends TrackingEvent {
  final String id;
  const LoadShipmentById(this.id);
  @override
  List<Object?> get props => [id];
}

final class RefreshShipment extends TrackingEvent {
  final String requestId;
  const RefreshShipment(this.requestId);
  @override
  List<Object?> get props => [requestId];
}
