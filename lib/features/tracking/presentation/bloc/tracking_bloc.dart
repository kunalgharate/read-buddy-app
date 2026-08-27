import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/usecases/tracking_usecases.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GetShipmentByRequest _getShipmentByRequest;
  final GetShipmentById _getShipmentById;

  // Remembers how the current shipment was loaded so RefreshShipment can
  // re-fetch using the correct source (by request id or by shipment id).
  String? _lastRequestId;
  String? _lastShipmentId;

  TrackingBloc({
    required GetShipmentByRequest getShipmentByRequest,
    required GetShipmentById getShipmentById,
  })  : _getShipmentByRequest = getShipmentByRequest,
        _getShipmentById = getShipmentById,
        super(TrackingInitial()) {
    on<LoadShipmentByRequest>(_onLoadShipmentByRequest);
    on<LoadShipmentById>(_onLoadShipmentById);
    on<RefreshShipment>(_onRefreshShipment);
  }

  Future<void> _onLoadShipmentByRequest(
    LoadShipmentByRequest event,
    Emitter<TrackingState> emit,
  ) async {
    _lastRequestId = event.requestId;
    _lastShipmentId = null;
    emit(TrackingLoading());
    try {
      final shipment = await _getShipmentByRequest(event.requestId);
      emit(TrackingLoaded(shipment));
    } catch (e) {
      emit(TrackingError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadShipmentById(
    LoadShipmentById event,
    Emitter<TrackingState> emit,
  ) async {
    _lastShipmentId = event.id;
    _lastRequestId = null;
    emit(TrackingLoading());
    try {
      final shipment = await _getShipmentById(event.id);
      emit(TrackingLoaded(shipment));
    } catch (e) {
      emit(TrackingError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onRefreshShipment(
    RefreshShipment event,
    Emitter<TrackingState> emit,
  ) async {
    // Preserve the currently loaded shipment so a failed refresh does not
    // wipe the data already on screen.
    final previous = state;
    try {
      final ShipmentEntity shipment;
      if (_lastShipmentId != null) {
        shipment = await _getShipmentById(_lastShipmentId!);
      } else {
        final requestId = _lastRequestId ?? event.requestId;
        shipment = await _getShipmentByRequest(requestId);
      }
      emit(TrackingLoaded(shipment));
    } catch (e) {
      if (previous is TrackingLoaded) {
        // Keep showing the last good data; surface the error transiently.
        emit(TrackingRefreshError(
            previous.shipment, ErrorHandler.getErrorMessage(e)));
        emit(previous);
      } else {
        emit(TrackingError(ErrorHandler.getErrorMessage(e)));
      }
    }
  }
}
