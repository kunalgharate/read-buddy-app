import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/donate/data/models/donation_stats_model.dart';
import 'package:read_buddy_app/features/donate/data/models/book_donation_request_model.dart';
import 'package:read_buddy_app/features/donate/data/models/agent_model.dart';

abstract class DonateRemoteDataSource {
  Future<DonationStatsModel> getDonationStats();
  Future<void> createBookDonation(BookDonationRequestModel request);
  Future<void> uploadReceipt(String donationId, FormData formData);
  Future<List<AgentModel>> getNearestAgents();
  Future<Map<String, dynamic>> initiateMoneyDonation(int amount);
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
        print('🌐 [DonateRemoteDataSource] Sending POST to: ${ApiConstants.createBookDonation}');
        print('📦 [DonateRemoteDataSource] Payload Data: $data');
      }

      final response = await dio.post(
        ApiConstants.createBookDonation,
        data: formData,
      );

      if (kDebugMode) {
        print('📡 [DonateRemoteDataSource] Response Status: ${response.statusCode}');
        print('📡 [DonateRemoteDataSource] Response Data: ${response.data}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['error'] ?? response.data['message'] ?? 'Failed to create donation');
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
  Future<List<AgentModel>> getNearestAgents() async {
    try {
      final response = await dio.get(ApiConstants.nearestAgent);
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        
        if (responseData is List) {
          return responseData.map((json) => AgentModel.fromJson(json)).toList();
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            return (responseData['data'] as List).map((json) => AgentModel.fromJson(json)).toList();
          } else if (responseData.containsKey('success') && responseData['success'] == true && responseData.containsKey('data')) {
             return (responseData['data'] as List).map((json) => AgentModel.fromJson(json)).toList();
          } else {
            return [AgentModel.fromJson(responseData)];
          }
        }
      }
      throw Exception(response.data?['message'] ?? 'Failed to load nearest agents');
    } catch (e) {
      throw Exception('Error fetching nearest agents: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> initiateMoneyDonation(int amount) async {
    final response = await dio.post(
      ApiConstants.donateMoneyInitiate,
      data: {'amount': amount},
    );
    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to initiate donation');
    }
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyMoneyDonation({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int amount,
  }) async {
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
      throw Exception(response.data?['error'] ?? 'Payment verification failed');
    }
    return response.data as Map<String, dynamic>;
  }
}