import 'package:dio/dio.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:read_buddy_app/features/donate/data/models/book_donation_request_model.dart';
import 'package:read_buddy_app/features/donate/domain/repositories/donate_repository.dart';
import 'package:read_buddy_app/features/donate/data/datasources/donate_remote_datasource.dart';

class DonateRepositoryImpl implements DonateRepository {
  final DonateRemoteDataSource remoteDataSource;

  DonateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DonationStats> getDonationStats() async {
    try {
      return await remoteDataSource.getDonationStats();
    } catch (e) {
      throw Exception('Failed to get donation stats: $e');
    }
  }

  @override
  Future<void> createBookDonation(BookDonationRequest request) async {
    try {
      final model = BookDonationRequestModel.fromEntity(request);
      await remoteDataSource.createBookDonation(model);
    } catch (e) {
      throw Exception('Failed to create book donation: $e');
    }
  }

  @override
  Future<void> uploadReceipt(String donationId, FormData formData) async {
    try {
      await remoteDataSource.uploadReceipt(donationId, formData);
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }
}
