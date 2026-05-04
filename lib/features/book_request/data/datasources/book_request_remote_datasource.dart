import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../models/book_detail_model.dart';
import '../models/book_request_model.dart';
import '../models/library_model.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/entities/pickup_details_entity.dart';

abstract class BookRequestRemoteDataSource {
  Future<BookDetailModel> getBookById(String id);
  Future<void> createBookRequest(String bookId);
  Future<List<BookRequestModel>> getMyBookRequests();
  Future<List<BookRequestModel>> getAllBookRequests();
  Future<List<BookRequestModel>> getUpcomingPickups();
  Future<void> cancelBookRequest(String id);
  Future<void> acceptBookRequest(String id, {String? notes});
  Future<void> declineBookRequest(String id, {String reason});
  Future<void> markAsDelivered(String id);
  Future<LibraryEntity> getLibraryDetails();
  Future<BookRequestModel> schedulePickup(PickupDetailsEntity details);
  Future<BookRequestModel> getRequestDetails(String id);
  Future<void> setFulfillment(String id, String method, String name, String phone, String? address);
  Future<void> confirmPayment(String id, int amount);
}

class BookRequestRemoteDataSourceImpl implements BookRequestRemoteDataSource {
  final Dio dio;
  final SecureStorageUtil secureStorage;

  BookRequestRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  @override
  Future<BookDetailModel> getBookById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.books}/$id');
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load book details');
      }
      return BookDetailModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createBookRequest(String bookId) async {
    try {
      final response = await dio.post(
        ApiConstants.userBookRequests,
        data: {
          'bookId': bookId,
          'fulfillmentMethod': 'PICKUP',
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to create book request');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookRequestModel>> getMyBookRequests() async {
    try {
      final response = await dio.get('${ApiConstants.v1BookRequests}/my');
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load book requests');
      }
      final List list = response.data is List
          ? response.data as List
          : (response.data['data'] is List ? response.data['data'] as List : []);
      return list
          .map((e) => BookRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookRequestModel>> getAllBookRequests() async {
    try {
      final response = await dio.get(ApiConstants.v1BookRequests);
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load all book requests');
      }
      final List list = response.data is List
          ? response.data as List
          : (response.data['data'] is List ? response.data['data'] as List : []);
      return list
          .map((e) => BookRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookRequestModel>> getUpcomingPickups() async {
    try {
      final response =
          await dio.get('${ApiConstants.v1BookRequests}/upcoming-pickups');
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load upcoming pickups');
      }
      final List list = response.data['data'] is List
          ? response.data['data'] as List
          : [];
      return list
          .map((e) => BookRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelBookRequest(String id) async {
    throw UnimplementedError('Cancel book request is not supported');
  }

  @override
  Future<void> acceptBookRequest(String id, {String? notes}) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/approve',
        data: {
          'status': 'approved',
          'notes': notes ?? 'Request approved',
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to approve book request');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineBookRequest(String id, {String reason = 'Request declined'}) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/reject',
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to decline book request');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAsDelivered(String id) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/deliver',
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to mark as delivered');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LibraryEntity> getLibraryDetails() async {
    try {
      final response = await dio.get(ApiConstants.libraryDetails);
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load library details');
      }
      return LibraryModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookRequestModel> getRequestDetails(String id) async {
    try {
      final response =
          await dio.get('${ApiConstants.v1BookRequests}/$id');
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load request details');
      }
      final data = response.data['data'] as Map<String, dynamic>;
      return BookRequestModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setFulfillment(
      String id, String method, String name, String phone, String? address) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/fulfillment',
        data: {
          'fulfillmentMethod': method,
          if (address != null) 'address': address,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to set fulfillment');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> confirmPayment(String id, int amount) async {
    try {
      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/$id/payment',
        data: {
          'amount': amount,
          'currency': 'INR',
          'paymentMethod': 'WALLET',
          'description': 'Shipping charges for Book Request',
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to confirm payment');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookRequestModel> schedulePickup(PickupDetailsEntity details) async {
    try {
      final d = details.pickupDate;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final timeParts = details.pickupTime.split(':');
      final hour24 = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts.length > 1 ? timeParts[1] : '00';
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 == 0
          ? 12
          : hour24 > 12
              ? hour24 - 12
              : hour24;
      final timeStr12 =
          '${hour12.toString().padLeft(2, '0')}:$minute $period';

      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/${details.requestId}/schedule-pickup',
        data: {
          'userName': details.userName,
          'phoneNumber': details.phoneNumber,
          'address': details.address,
          'pickupDate': dateStr,
          'pickupTime': timeStr12,
        },
      );

      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to schedule pickup');
      }

      final responseData = response.data;
      final data = responseData['data'] as Map<String, dynamic>;
      return BookRequestModel.fromJson(data);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      final statusCode = e.response?.statusCode;
      if (statusCode == ApiConstants.notFound) {
        throw Exception(
            serverMsg ?? 'Book request not found or not eligible for pickup');
      }
      if (statusCode == ApiConstants.badRequest) {
        throw Exception(
            serverMsg ?? 'Invalid pickup details. Please check your input.');
      }
      throw Exception(
          serverMsg ?? 'Failed to schedule pickup. Please try again.');
    } catch (e) {
      rethrow;
    }
  }
}
