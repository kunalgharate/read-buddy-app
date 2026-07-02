import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/features/library/data/models/library_model.dart';

abstract class LibrarianRemoteDataSource {
  Future<LibraryModel> getMyLibrary();
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getBookRequests();
  Future<void> acceptRequest(String id);
  Future<void> rejectRequest(String id, String reason);
  Future<void> updateRequestStatus(String id, String status);
  Future<List<Map<String, dynamic>>> getDonations();
  Future<void> updateDonationStatus(String id, String status);
  Future<void> scheduleDonationPickup(String id, Map<String, dynamic> data);
}

class LibrarianRemoteDataSourceImpl implements LibrarianRemoteDataSource {
  final Dio _dio;
  LibrarianRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<LibraryModel> getMyLibrary() async {
    final response = await _dio.get(ApiConstants.librarianMyLibrary);
    final data = response.data;
    final json = data['library'] ?? data;
    return LibraryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get(ApiConstants.librarianDashboard);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getBookRequests() async {
    final response = await _dio.get(ApiConstants.librarianBookRequests);
    final data = response.data;
    final list = data['requests'] ?? data['data'] ?? data;
    return list is List ? List<Map<String, dynamic>>.from(list) : [];
  }

  @override
  Future<void> acceptRequest(String id) async {
    await _dio.patch(ApiConstants.librarianRequestAccept(id));
  }

  @override
  Future<void> rejectRequest(String id, String reason) async {
    await _dio.patch(
      ApiConstants.librarianRequestReject(id),
      data: {'reason': reason},
    );
  }

  @override
  Future<void> updateRequestStatus(String id, String status) async {
    await _dio.patch(
      ApiConstants.librarianRequestStatus(id),
      data: {'status': status},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDonations() async {
    final response = await _dio.get(ApiConstants.librarianDonations);
    final data = response.data;
    final list = data['donations'] ?? data['data'] ?? data;
    return list is List ? List<Map<String, dynamic>>.from(list) : [];
  }

  @override
  Future<void> updateDonationStatus(String id, String status) async {
    await _dio.patch(
      ApiConstants.librarianDonationStatus(id),
      data: {'status': status},
    );
  }

  @override
  Future<void> scheduleDonationPickup(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _dio.patch(
      ApiConstants.librarianDonationSchedulePickup(id),
      data: data,
    );
  }
}
