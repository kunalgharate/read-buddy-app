import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AddressEntity>> getAddresses() =>
      _remoteDataSource.getAddresses();

  @override
  Future<AddressEntity> createAddress(Map<String, dynamic> data) =>
      _remoteDataSource.createAddress(data);

  @override
  Future<AddressEntity> updateAddress(String id, Map<String, dynamic> data) =>
      _remoteDataSource.updateAddress(id, data);

  @override
  Future<void> deleteAddress(String id) => _remoteDataSource.deleteAddress(id);
}
