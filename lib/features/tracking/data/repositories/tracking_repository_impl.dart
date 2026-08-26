import '../../domain/entities/shipment_entity.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_remote_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource _remoteDataSource;

  TrackingRepositoryImpl(this._remoteDataSource);

  @override
  Future<ShipmentEntity> getShipmentByRequest(String requestId) =>
      _remoteDataSource.getShipmentByRequest(requestId);

  @override
  Future<ShipmentEntity> getShipmentById(String id) =>
      _remoteDataSource.getShipmentById(id);
}
