import '../entities/shipment_entity.dart';

abstract class TrackingRepository {
  Future<ShipmentEntity> getShipmentByRequest(String requestId);
  Future<ShipmentEntity> getShipmentById(String id);
}
