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
    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('addresses')) {
      list = data['addresses'] as List;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.addresses, data: data);
    final responseData = response.data;
    final json = responseData is Map && responseData.containsKey('address')
        ? responseData['address']
        : responseData;
    return AddressModel.fromJson(json as Map<String, dynamic>);
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
    final responseData = response.data;
    final json = responseData is Map && responseData.containsKey('address')
        ? responseData['address']
        : responseData;
    return AddressModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete('${ApiConstants.addresses}/$id');
  }
}
