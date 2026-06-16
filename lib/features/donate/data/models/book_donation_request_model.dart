import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/book_donation_request.dart';

class BookDonationRequestModel extends BookDonationRequest {
  const BookDonationRequestModel({
    required super.fulfillmentType,
    required super.bookDetails,
    super.pickupDetails,
    super.dropoffDetails,
    super.bookImagePath,
    super.receiptImagePath,
  });

  factory BookDonationRequestModel.fromEntity(BookDonationRequest entity) {
    return BookDonationRequestModel(
      fulfillmentType: entity.fulfillmentType,
      bookDetails: entity.bookDetails,
      pickupDetails: entity.pickupDetails,
      dropoffDetails: entity.dropoffDetails,
      bookImagePath: entity.bookImagePath,
      receiptImagePath: entity.receiptImagePath,
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    // ── Core book fields (matches server schema) ──────────────
    final Map<String, dynamic> data = {
      'fulfillmentType': fulfillmentType,
      'bookDetails': {
        'bookName': bookDetails.bookName,
        'category': bookDetails.category,
        'condition': bookDetails.condition,
        'description': bookDetails.description,
        'language': bookDetails.language,
        'format': bookDetails.format ?? 'physical',
      },
    };

    // ── Pickup details (key: 'pickup', phone key: 'mobile') ───
    if (fulfillmentType == 'PICKUP' && pickupDetails != null) {
      final Map<String, dynamic> pickup = {
        'name': pickupDetails!.name,
        'address': pickupDetails!.address,
        'pincode': pickupDetails!.pincode,
        'mobile': pickupDetails!.mobile,
      };

      // Only add lat/lng if present
      if (pickupDetails!.latitude != null) {
        pickup['latitude'] = pickupDetails!.latitude;
      }
      if (pickupDetails!.longitude != null) {
        pickup['longitude'] = pickupDetails!.longitude;
      }

      // Preferred date/time for pickup scheduling
      if (pickupDetails!.preferredDate != null) {
        pickup['preferredDate'] = pickupDetails!.preferredDate;
      }
      if (pickupDetails!.preferredTime != null) {
        pickup['preferredTime'] = pickupDetails!.preferredTime;
      }

      data['pickup'] = pickup; // ✅ server expects 'pickup' not 'pickupDetails'
    }

    // ── Dropoff details (key: 'dropoff') ──────────────────────
    if (fulfillmentType == 'DROP_OFF' && dropoffDetails != null) {
      data['dropoff'] = {
        'libraryId': dropoffDetails!.libraryId, // ✅ server expects 'dropoff' not 'dropoffDetails'
      };
    }

    // ── Book cover image (optional) ───────────────────────────
    if (bookImagePath != null && bookImagePath!.isNotEmpty) {
      data['bookImage'] = await MultipartFile.fromFile(
        bookImagePath!,
        filename: bookImagePath!.split('/').last,
      );
    }

    // ── Receipt image (optional, dropoff only) ────────────────
    if (receiptImagePath != null && receiptImagePath!.isNotEmpty) {
      data['receiptImage'] = await MultipartFile.fromFile(
        receiptImagePath!,
        filename: receiptImagePath!.split('/').last,
      );
    }

    if (kDebugMode) {
      print('📦 [BookDonationRequestModel] Payload:');
      print('   fulfillmentType: ${data['fulfillmentType']}');
      print('   bookDetails: ${data['bookDetails']}');
      if (data.containsKey('pickup')) print('   pickup: ${data['pickup']}');
      if (data.containsKey('dropoff')) print('   dropoff: ${data['dropoff']}');
    }

    return data;
  }
}