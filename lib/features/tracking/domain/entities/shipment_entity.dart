import 'package:equatable/equatable.dart';

class ShipmentEntity extends Equatable {
  final String id;
  final String requestId;
  final String trackingId;
  final String courier;
  final String status;
  final String? receiptImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShipmentEntity({
    required this.id,
    required this.requestId,
    required this.trackingId,
    required this.courier,
    required this.status,
    this.receiptImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        requestId,
        trackingId,
        courier,
        status,
        receiptImageUrl,
        createdAt,
        updatedAt,
      ];
}
