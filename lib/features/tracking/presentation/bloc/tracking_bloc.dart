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
    try {
      final shipment = await _getShipmentByRequest(event.requestId);
      emit(TrackingLoaded(shipment));
    } catch (e) {
      emit(TrackingError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
