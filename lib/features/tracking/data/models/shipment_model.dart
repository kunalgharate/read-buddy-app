import '../../domain/entities/shipment_entity.dart';

class ShipmentModel extends ShipmentEntity {
  const ShipmentModel({
    required super.id,
    required super.requestId,
    required super.trackingId,
    required super.courier,
    required super.status,
    super.receiptImageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ??
          json['bookRequestId']?.toString() ??
          '',
      // Backend uses 'trackingNumber' (see ShipmentTrackingWidget); accept
      // 'trackingId' as a fallback.
      trackingId: json['trackingNumber']?.toString() ??
          json['trackingId']?.toString() ??
          '',
      // Backend uses 'carrier'; accept 'courier' as a fallback.
      courier: json['carrier']?.toString() ?? json['courier']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ordered',
      receiptImageUrl:
          json['receiptImageUrl']?.toString() ?? json['receiptUrl']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'requestId': requestId,
        'trackingNumber': trackingId,
        'carrier': courier,
        'status': status,
        'receiptImageUrl': receiptImageUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
