import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> createAddress(Map<String, dynamic> data);
  Future<AddressEntity> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
}
