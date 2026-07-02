import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.name,
    required super.phone,
    required super.addressLine1,
    required super.addressLine2,
    required super.city,
    required super.state,
    required super.pincode,
    required super.latitude,
    required super.longitude,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine1: json['addressLine1']?.toString() ?? json['address']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'name': name,
        'phone': phone,
        'address': [addressLine1, addressLine2, city, state, pincode]
            .where((s) => s.isNotEmpty)
            .join(', '),
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}
