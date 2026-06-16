import 'package:equatable/equatable.dart';

class BookDonationRequest extends Equatable {
  final String fulfillmentType; // 'PICKUP' or 'DROP_OFF'
  final BookDetails bookDetails;
  final PickupDetails? pickupDetails;
  final DropoffDetails? dropoffDetails;
  final String? bookImagePath;
  final String? receiptImagePath;

  const BookDonationRequest({
    required this.fulfillmentType,
    required this.bookDetails,
    this.pickupDetails,
    this.dropoffDetails,
    this.bookImagePath,
    this.receiptImagePath,
  });

  @override
  List<Object?> get props => [
    fulfillmentType,
    bookDetails,
    pickupDetails,
    dropoffDetails,
    bookImagePath,
    receiptImagePath,
  ];
}

class BookDetails extends Equatable {
  final String bookName; // ✅ renamed from 'title' to match server
  final String? category;
  final String? condition;
  final String? description;
  final String? language;
  final String? format;

  const BookDetails({
    required this.bookName, // ✅
    this.category,
    this.condition,
    this.description,
    this.language,
    this.format,
  });

  @override
  List<Object?> get props => [
    bookName,
    category,
    condition,
    description,
    language,
    format,
  ];
}

class PickupDetails extends Equatable {
  final String? name;
  final String address;
  final String pincode;
  final String mobile; // ✅ renamed from 'phoneNumber' to match server
  final String? preferredDate; // DD/MM/YYYY
  final String? preferredTime; // HH:mm
  final double? latitude;
  final double? longitude;

  const PickupDetails({
    this.name,
    required this.address,
    required this.pincode,
    required this.mobile, // ✅
    this.preferredDate,
    this.preferredTime,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    name,
    address,
    pincode,
    mobile,
    preferredDate,
    preferredTime,
    latitude,
    longitude,
  ];
}

class DropoffDetails extends Equatable {
  final String libraryId;

  const DropoffDetails({required this.libraryId});

  @override
  List<Object?> get props => [libraryId];
}