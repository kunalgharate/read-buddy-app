import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';

class MoneyDonationRecord {
  final String id;
  final int amount;
  final String status;
  final String createdAt;

  const MoneyDonationRecord({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory MoneyDonationRecord.fromJson(Map<String, dynamic> json) {
    return MoneyDonationRecord(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      // Preserve the API status verbatim. Do NOT default a missing status to a
      // confirmed value, otherwise unconfirmed donations would be counted in
      // the user's total. Unknown/missing statuses fall to 'pending' so the
      // confirmed-total logic only counts explicitly confirmed statuses.
      status: (json['status'] ?? 'pending').toString(),
      // The money-donation API may return the date as 'donationDate'; fall back
      // to 'createdAt'/'created_at' so history rows never show a blank date.
      createdAt: (json['donationDate'] ??
              json['createdAt'] ??
              json['created_at'] ??
              '')
          .toString(),
    );
  }
}

class MoneyDonationService {
  final Dio _dio;

  MoneyDonationService(this._dio);

  Future<List<MoneyDonationRecord>> fetchMyMoneyDonations() async {
    final response = await _dio.get(ApiConstants.myMoneyDonations);
    if (response.statusCode == 200) {
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        list = data['donations'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [];
      } else {
        list = [];
      }
      return list
          .map((e) => MoneyDonationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
