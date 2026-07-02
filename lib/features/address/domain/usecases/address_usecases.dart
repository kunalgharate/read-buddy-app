import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddresses {
  final AddressRepository _repository;
  GetAddresses(this._repository);

  Future<List<AddressEntity>> call() => _repository.getAddresses();
}

class CreateAddress {
  final AddressRepository _repository;
  CreateAddress(this._repository);

  Future<AddressEntity> call(Map<String, dynamic> data) =>
      _repository.createAddress(data);
}

class UpdateAddress {
  final AddressRepository _repository;
  UpdateAddress(this._repository);

  Future<AddressEntity> call(String id, Map<String, dynamic> data) =>
      _repository.updateAddress(id, data);
}

class DeleteAddress {
  final AddressRepository _repository;
  DeleteAddress(this._repository);

  Future<void> call(String id) => _repository.deleteAddress(id);
}
