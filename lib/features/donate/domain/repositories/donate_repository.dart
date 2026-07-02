import 'package:dio/dio.dart';

import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';

abstract class DonateRepository {
  Future<DonationStats> getDonationStats();
  Future<void> createBookDonation(BookDonationRequest request);
  Future<void> uploadReceipt(String donationId, FormData formData);
}
