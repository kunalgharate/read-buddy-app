import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/shipment_model.dart';

abstract class TrackingRemoteDataSource {
  Future<ShipmentModel> getShipmentByRequest(String requestId);
  Future<ShipmentModel> getShipmentById(String id);
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final Dio _dio;

  TrackingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  /// Safely unwrap a `{ data: {...} }` envelope (or bare object) into a Map.
  Map<String, dynamic> _unwrap(dynamic data) {
    final raw = data is Map && data.containsKey('data') ? data['data'] : data;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    throw Exception('No shipment information available yet');
  }

  @override
  Future<ShipmentModel> getShipmentByRequest(String requestId) async {
    final response = await _dio.get(
      ApiConstants.shipmentByRequest(requestId),
    );
    return ShipmentModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<ShipmentModel> getShipmentById(String id) async {
    final response = await _dio.get(
      ApiConstants.shipmentById(id),
    );
    return ShipmentModel.fromJson(_unwrap(response.data));
  }
}
