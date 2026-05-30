import 'package:dio/dio.dart';

import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:read_buddy_app/features/donate/domain/entities/agent.dart';

import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/domain/entities/user_book_status.dart';
import 'package:read_buddy_app/features/donate/domain/entities/user_location.dart';


abstract class DonateRepository {
  Future<DonationStats> getDonationStats();
  Future<void> createBookDonation(BookDonationRequest request);
  Future<void> uploadReceipt(String donationId, FormData formData);
  Future<List<Agent>> getNearestAgents();
  Future<AgentAddress> getUserLocation();
  Future<UserBookStatus> getUserBookStatus();
}

