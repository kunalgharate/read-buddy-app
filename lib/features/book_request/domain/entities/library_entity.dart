import 'package:equatable/equatable.dart';

class LibraryEntity extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final String openHours;
  final LibraryAddressEntity address;

  const LibraryEntity({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.openHours,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, contactNumber, openHours, address];
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

  String get fullAddress => '$street, $city, $state – $pincode';

  @override
  List<Object?> get props =>
      [street, city, state, country, pincode, latitude, longitude];
}
