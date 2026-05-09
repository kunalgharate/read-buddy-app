import 'package:read_buddy_app/features/donate/domain/entities/agent.dart';

class AgentModel extends Agent {
  const AgentModel({
    required super.id,
    required super.name,
    required super.contactNumber,
    required super.openHours,
    required AgentAddressModel super.location,
    required super.rating,
    required super.totalDeliveries,
    required super.isAvailable,
    required super.distanceKm,
    super.estimatedPickupTimeMin,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      openHours: json['openHours'] ?? '',
      location: AgentAddressModel.fromJson(json['address'] ?? {}),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      estimatedPickupTimeMin: json['estimatedPickupTimeMin'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactNumber': contactNumber,
      'openHours': openHours,
      'address': (location as AgentAddressModel).toJson(),
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'isAvailable': isAvailable,
      'distanceKm': distanceKm,
      'estimatedPickupTimeMin': estimatedPickupTimeMin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AgentAddressModel extends AgentAddress {
  const AgentAddressModel({
    required super.country,
    required super.street,
    required super.city,
    required super.state,
    required super.pincode,
    required super.latitude,
    required super.longitude,
    required super.address,
  });

  factory AgentAddressModel.fromJson(Map<String, dynamic> json) {
    final street = json['street'] ?? '';
    final city = json['city'] ?? '';
    final state = json['state'] ?? '';
    final pincode = json['pincode'] ?? '';
    final fullAddress = json['address'] ?? '$street, $city, $state - $pincode';

    return AgentAddressModel(
      country: json['country'] ?? '',
      street: street,
      city: city,
      state: state,
      pincode: pincode,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: fullAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}