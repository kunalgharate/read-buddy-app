import '../../domain/entities/library_entity.dart';

class LibraryModel extends LibraryEntity {
  const LibraryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.address,
    required super.contactNumber,
    required super.openHours,
    required super.isSuperLibrary,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) {
    return LibraryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      address: LibraryAddressModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
      contactNumber: json['contactNumber']?.toString() ?? '',
      openHours: json['openHours']?.toString() ?? '',
      isSuperLibrary: json['isSuperLibrary'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'address': (address as LibraryAddressModel).toJson(),
        'contactNumber': contactNumber,
        'openHours': openHours,
        'isSuperLibrary': isSuperLibrary,
      };
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
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      pincode: json['pincode']?.toString() ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
      };
}
