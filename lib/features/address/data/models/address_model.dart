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
    // Parse individual fields first
    String line1 = json['addressLine1']?.toString() ?? '';
    String line2 = json['addressLine2']?.toString() ?? '';
    String city = json['city']?.toString() ?? '';
    String state = json['state']?.toString() ?? '';
    String pincode = json['pincode']?.toString() ?? '';

    // Fallback: if individual fields are empty but combined `address` exists,
    // use it only for line1 (don't try to split since we can't reliably parse).
    if (line1.isEmpty && json['address'] != null) {
      line1 = json['address'].toString();
    }

    return AddressModel(
      id: json['_id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine1: line1,
      addressLine2: line2,
      city: city,
      state: state,
      pincode: pincode,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'name': name,
        'phone': phone,
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
