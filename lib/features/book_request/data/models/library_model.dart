import '../../domain/entities/library_entity.dart';

class LibraryModel extends LibraryEntity {
  const LibraryModel({
    required super.id,
    required super.name,
    required super.contactNumber,
    required super.openHours,
    required super.address,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    final addr = json['address'] as Map<String, dynamic>;
    return LibraryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      openHours: json['openHours'] ?? '',
      address: LibraryAddressModel.fromJson(addr),
    );
  }
}

class LibraryAddressModel extends LibraryAddressEntity {
  const LibraryAddressModel({
    required super.street,
    required super.city,
    required super.state,
    required super.country,
    required super.pincode,
    required super.latitude,
    required super.longitude,
  });

  factory LibraryAddressModel.fromJson(Map<String, dynamic> json) {
    return LibraryAddressModel(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
