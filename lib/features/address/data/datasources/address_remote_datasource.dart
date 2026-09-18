import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio _dio;

  AddressRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get(ApiConstants.addresses);
    final data = response.data;

    // Handle both array response and { addresses: [...] }
    List list = const [];
    if (data is List) {
      list = data;
    } else if (data is Map && data['addresses'] is List) {
      list = data['addresses'] as List;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    }

    return list
        .whereType<Map>()
        .map((json) => AddressModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.addresses, data: data);
    return _buildModel(response.data, data);
  }

  @override
  Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '${ApiConstants.addresses}/$id',
      data: data,
    );
    final fallback = Map<String, dynamic>.from(data)
      ..putIfAbsent('_id', () => id);
    return _buildModel(response.data, fallback);
  }

  /// Extracts an address map from any server response shape. Falls back to
  /// [fallback] when the response only carries a message or is not a map, so a
  /// successful save never fails on parsing.
  AddressModel _buildModel(dynamic responseData, Map<String, dynamic> fallback) {
    if (responseData is Map) {
      final nested =
          responseData['address'] ?? responseData['data'] ?? responseData;
      if (nested is Map &&
          (nested.containsKey('_id') ||
              nested.containsKey('addressLine1') ||
              nested.containsKey('label'))) {
        return AddressModel.fromJson(Map<String, dynamic>.from(nested));
      }
    }
    return AddressModel.fromJson(fallback);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete('${ApiConstants.addresses}/$id');
  }
}
