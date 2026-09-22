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
    return buildAddressModel(response.data, data);
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
    return buildAddressModel(response.data, fallback);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete('${ApiConstants.addresses}/$id');
  }
}

/// Extracts an address map from any server response shape and falls back to
/// [fallback] when the response only carries a message or is not a map, so a
/// successful save never fails on parsing.
AddressModel buildAddressModel(
  dynamic responseData,
  Map<String, dynamic> fallback,
) {
  return AddressModel.fromJson(_asAddressMap(responseData) ?? fallback);
}

/// Returns the address document map from a response body, or `null` when the
/// body is not an address payload (e.g. a plain message).
Map<String, dynamic>? _asAddressMap(dynamic responseData) {
  if (responseData is! Map) return null;
  final address = responseData['address'];
  final data = responseData['data'];
  if (address is Map) return Map<String, dynamic>.from(address);
  if (data is Map) return Map<String, dynamic>.from(data);
  if (responseData.containsKey('_id') ||
      responseData.containsKey('addressLine1') ||
      responseData.containsKey('addressLine2') ||
      responseData.containsKey('label') ||
      responseData.containsKey('city')) {
    return Map<String, dynamic>.from(responseData);
  }
  return null;
}
