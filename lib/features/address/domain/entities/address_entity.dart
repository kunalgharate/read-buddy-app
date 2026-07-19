import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  String get fullAddress => [addressLine1, addressLine2, city, state, pincode]
      .where((s) => s.isNotEmpty)
      .join(', ');

  @override
  List<Object?> get props => [
        id,
        label,
        name,
        phone,
        addressLine1,
        addressLine2,
        city,
        state,
        pincode,
        latitude,
        longitude,
        isDefault,
      ];
}
