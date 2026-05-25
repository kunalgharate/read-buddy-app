import 'package:equatable/equatable.dart';

class Agent extends Equatable {
  final String id;
  final String name;
  final String contactNumber;
  final String openHours;
  final AgentAddress location;
  final double rating;
  final int totalDeliveries;
  final bool isAvailable;
  final double distanceKm;
  final int? estimatedPickupTimeMin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Agent({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.openHours,
    required this.location,
    required this.rating,
    required this.totalDeliveries,
    required this.isAvailable,
    required this.distanceKm,
    this.estimatedPickupTimeMin,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        contactNumber,
        openHours,
        location,
        rating,
        totalDeliveries,
        isAvailable,
        distanceKm,
        estimatedPickupTimeMin
      ];
}

class AgentAddress extends Equatable {
  final String country;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final String address;

  const AgentAddress({
    required this.country,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props =>
      [country, street, city, state, pincode, latitude, longitude, address];
}