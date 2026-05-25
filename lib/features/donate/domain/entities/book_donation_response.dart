import 'package:equatable/equatable.dart';

class BookDonationResponse extends Equatable {
  final String id;
  final String donorId;
  final String title;
  final String? description;
  final String? language;
  final String format;
  final String? condition;
  final String? category;
  final String? coverImageUrl;
  final String fulfillmentType;
  final PickupDetailsResponse? pickupDetails;
  final DropoffDetailsResponse? dropoffDetails;
  final String status;
  final List<StatusTimelineItem> statusTimeline;
  final DateTime createdAt;

  const BookDonationResponse({
    required this.id,
    required this.donorId,
    required this.title,
    this.description,
    this.language,
    required this.format,
    this.condition,
    this.category,
    this.coverImageUrl,
    required this.fulfillmentType,
    this.pickupDetails,
    this.dropoffDetails,
    required this.status,
    required this.statusTimeline,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        donorId,
        title,
        description,
        language,
        format,
        condition,
        category,
        coverImageUrl,
        fulfillmentType,
        pickupDetails,
        dropoffDetails,
        status,
        statusTimeline,
        createdAt,
      ];
}

class PickupDetailsResponse extends Equatable {
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const PickupDetailsResponse({
    this.name,
    this.phoneNumber,
    this.address,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        name,
        phoneNumber,
        address,
        pincode,
        latitude,
        longitude,
      ];
}

class DropoffDetailsResponse extends Equatable {
  final String? libraryId;
  final String? libraryName;

  const DropoffDetailsResponse({
    this.libraryId,
    this.libraryName,
  });

  @override
  List<Object?> get props => [libraryId, libraryName];
}

class StatusTimelineItem extends Equatable {
  final String status;
  final DateTime timestamp;
  final String? message;

  const StatusTimelineItem({
    required this.status,
    required this.timestamp,
    this.message,
  });

  @override
  List<Object?> get props => [status, timestamp, message];
}
