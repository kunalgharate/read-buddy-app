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

  @override
  Future<ShipmentModel> getShipmentByRequest(String requestId) async {
    final response = await _dio.get(
      ApiConstants.shipmentByRequest(requestId),
    );
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return ShipmentModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<ShipmentModel> getShipmentById(String id) async {
    final response = await _dio.get(
      ApiConstants.shipmentById(id),
    );
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return ShipmentModel.fromJson(json as Map<String, dynamic>);
  }
}
