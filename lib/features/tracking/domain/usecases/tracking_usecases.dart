import '../entities/shipment_entity.dart';
import '../repositories/tracking_repository.dart';

class GetShipmentByRequest {
  final TrackingRepository _repository;
  GetShipmentByRequest(this._repository);

  Future<ShipmentEntity> call(String requestId) =>
      _repository.getShipmentByRequest(requestId);
}

class GetShipmentById {
  final TrackingRepository _repository;
  GetShipmentById(this._repository);

  Future<ShipmentEntity> call(String id) => _repository.getShipmentById(id);
}
