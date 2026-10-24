import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/donate/data/models/donation_stats_model.dart';
import 'package:read_buddy_app/features/donate/data/models/book_donation_request_model.dart';

abstract class DonateRemoteDataSource {
  Future<DonationStatsModel> getDonationStats();
  Future<void> createBookDonation(BookDonationRequestModel request);
  Future<void> uploadReceipt(String donationId, FormData formData);
  Future<Map<String, dynamic>> initiateMoneyDonation(
    int amount, {
    String currency = 'INR',
  });
  Future<Map<String, dynamic>> verifyMoneyDonation({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int amount,
  });
}

class DonateRemoteDataSourceImpl implements DonateRemoteDataSource {
  final Dio dio;

  DonateRemoteDataSourceImpl({required this.dio});

  // GET /api/v1/donations/my-impact
  @override
  Future<DonationStatsModel> getDonationStats() async {
    try {
      final response = await dio.get(ApiConstants.myImpact);
      if (response.statusCode == 200) {
        // Handle cases where data might be directly in response or under a key
        return DonationStatsModel.fromJson(response.data);
      }
      throw Exception(response.data?['message'] ?? 'Failed to load stats');
    } catch (e) {
      throw Exception('Error fetching donation stats: $e');
    }
  }

  // POST /api/v1/donations/createBookDonation
  @override
  Future<void> createBookDonation(BookDonationRequestModel request) async {
    try {
      final data = await request.toMap();
      final formData = FormData.fromMap(data);

      if (kDebugMode) {
        print(
          '🌐 [DonateRemoteDataSource] Sending POST to: ${ApiConstants.createBookDonation}',
        );
        print('📦 [DonateRemoteDataSource] Payload Data: $data');
      }

      final response = await dio.post(
        ApiConstants.createBookDonation,
        data: formData,
      );

      if (kDebugMode) {
        print(
          '📡 [DonateRemoteDataSource] Response Status: ${response.statusCode}',
        );
        print('📡 [DonateRemoteDataSource] Response Data: ${response.data}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data['error'] ??
              response.data['message'] ??
              'Failed to create donation',
        );
      }
    } catch (e) {
      if (kDebugMode) print('🔥 [DonateRemoteDataSource] Error: $e');
      throw Exception('Error creating donation: $e');
    }
  }

  // POST /api/v1/donations/:id/uploadReceipt
  @override
  Future<void> uploadReceipt(String donationId, FormData formData) async {
    try {
      final response = await dio.post(
        ApiConstants.uploadDonationReceipt(donationId),
        data: formData,
      );
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to upload receipt');
      }
    } catch (e) {
      throw Exception('Error uploading receipt: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> initiateMoneyDonation(
    int amount, {
    String currency = 'INR',
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.donateMoneyInitiate,
        data: {
          'amount': amount,
          'currency': currency,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data?['error'] ??
              response.data?['message'] ??
              'Failed to initiate donation',
        );
      }
      final raw = response.data;
      if (raw is Map) {
        final Map map = raw['data'] is Map ? raw['data'] as Map : raw;
        return Map<String, dynamic>.from(map);
      }
      throw Exception('Unexpected response from payment server');
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['error'] ?? e.response!.data['message'])
              as String?
          : null;
      throw Exception(serverMsg ?? 'Failed to initiate donation');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyMoneyDonation({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int amount,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.donateMoneyVerify,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'amount': amount,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(
          response.data?['error'] ??
              response.data?['message'] ??
              'Payment verification failed',
        );
      }
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['error'] ?? e.response!.data['message'])
              as String?
          : null;
      throw Exception(serverMsg ?? 'Payment verification failed');
    }
  }
}
