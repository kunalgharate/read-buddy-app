import 'package:equatable/equatable.dart';

class PickupDetailsEntity extends Equatable {
  final String requestId;
  final String userName;
  final String phoneNumber;
  final String address;
  final DateTime pickupDate;
  final String pickupTime; // "HH:mm" 24-hour format

  const PickupDetailsEntity({
    required this.requestId,
    required this.userName,
    required this.phoneNumber,
    required this.address,
    required this.pickupDate,
    required this.pickupTime,
  });

  @override
  List<Object?> get props => [
        requestId,
        userName,
        phoneNumber,
        address,
        pickupDate,
        pickupTime,
      ];
}
