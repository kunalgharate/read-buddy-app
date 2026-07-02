import 'package:equatable/equatable.dart';

class LibraryEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final LibraryAddressEntity address;
  final String contactNumber;
  final String openHours;
  final bool isSuperLibrary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LibraryEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.address,
    required this.contactNumber,
    required this.openHours,
    required this.isSuperLibrary,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        address,
        contactNumber,
        openHours,
        isSuperLibrary,
      ];
}

class LibraryAddressEntity extends Equatable {
  final String street;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double latitude;
  final double longitude;

  const LibraryAddressEntity({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  String get fullAddress =>
      [street, city, state, pincode].where((s) => s.isNotEmpty).join(', ');

  @override
  List<Object?> get props =>
      [street, city, state, country, pincode, latitude, longitude];
}
