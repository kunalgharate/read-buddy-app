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
  Future<String> createBookRequest(
    String bookId,
    String fulfillmentMethod, {
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryPincode,
    String? deliveryPreferredDate,
  });
  Future<List<BookRequestModel>> getMyBookRequests();
  Future<List<BookRequestModel>> getAllBookRequests();
  Future<List<BookRequestModel>> getUpcomingPickups();
  Future<void> cancelBookRequest(String id, String reason);
  Future<void> acceptBookRequest(String id, {String? notes});
  Future<void> declineBookRequest(String id, {String reason});
  Future<LibraryEntity> getLibraryDetails();
  Future<BookRequestModel> schedulePickup(PickupDetailsEntity details);
  Future<BookRequestModel> getRequestDetails(String id);
  Future<void> updateRequestStatus(String id, String status);
  Future<void> scheduleDelivery(
      String id,
      String name,
      String phone,
      String address,
      String pincode,
      String preferredDate,
      String preferredTime);
  Future<void> initiateReturn(String id, String returnMethod,
      {String? returnBranchId});
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
      final decoded = response.data;
      final bookData = decoded is Map
          ? (decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'])
              : Map<String, dynamic>.from(decoded))
          : <String, dynamic>{};
      return BookDetailModel.fromJson(bookData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createBookRequest(
    String bookId,
    String fulfillmentMethod, {
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryPincode,
    String? deliveryPreferredDate,
  }) async {
    try {
      final body = <String, dynamic>{
        'bookId': bookId,
        'fulfillmentMethod': 'PICKUP',
      };
      if (deliveryName != null) body['deliveryName'] = deliveryName;
      if (deliveryPhone != null) body['deliveryPhone'] = deliveryPhone;
      if (deliveryAddress != null) body['deliveryAddress'] = deliveryAddress;
      if (deliveryPincode != null) body['deliveryPincode'] = deliveryPincode;
      if (deliveryPreferredDate != null) body['deliveryPreferredDate'] = deliveryPreferredDate;

      final response = await dio.post(
        ApiConstants.userBookRequests,
        data: body,
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to create book request');
      }
      final decoded = response.data;
      final data = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'])
          : decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
      return data['_id'] as String? ?? '';
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
          : (response.data['data'] is List
              ? response.data['data'] as List
              : []);
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
          : (response.data['data'] is List
              ? response.data['data'] as List
              : []);
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
  Future<void> cancelBookRequest(String id, String reason) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.v1BookRequests}/$id',
        data: {'reason': reason},
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to cancel book request');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptBookRequest(String id, {String? notes}) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/approve',
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to approve book request');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error']) as String?
          : null;
      throw Exception(serverMsg ?? 'Failed to approve request. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineBookRequest(String id,
      {String reason = 'Request declined'}) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/reject',
        data: {'reason': reason},
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
  Future<LibraryEntity> getLibraryDetails() async {
    try {
      final response = await dio.get(ApiConstants.libraryDetails);
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load library details');
      }
      final decoded = response.data;
      final libraryData = decoded is Map
          ? (decoded['data'] is Map
              ? Map<String, dynamic>.from(decoded['data'])
              : Map<String, dynamic>.from(decoded))
          : <String, dynamic>{};
      return LibraryModel.fromJson(libraryData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookRequestModel> getRequestDetails(String id) async {
    try {
      final response = await dio.get('${ApiConstants.v1BookRequests}/$id');
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load request details');
      }
      final decoded = response.data;
      final data = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'])
          : decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
      return BookRequestModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRequestStatus(String id, String status) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.v1BookRequests}/$id/status',
        data: {'status': status},
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> scheduleDelivery(
      String id,
      String name,
      String phone,
      String address,
      String pincode,
      String preferredDate,
      String preferredTime) async {
    try {
      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/$id/deliver-to-me',
        data: {
          'name': name,
          'phone': phone,
          'address': address,
          'pincode': pincode,
          'preferredDate': preferredDate,
          'preferredTime': preferredTime,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to schedule delivery');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(
          serverMsg ?? 'Failed to schedule delivery. Please try again.');
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
      final timeStr12 = '${hour12.toString().padLeft(2, '0')}:$minute $period';

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
      final data = responseData is Map && responseData['data'] is Map
          ? Map<String, dynamic>.from(responseData['data'])
          : responseData is Map ? Map<String, dynamic>.from(responseData) : <String, dynamic>{};
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

  @override
  Future<void> initiateReturn(String id, String returnMethod,
      {String? returnBranchId}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/$id/initiate-return',
        data: {
          'returnMethod': returnMethod,
          if (returnBranchId != null) 'returnBranchId': returnBranchId,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to initiate return');
      }
    } catch (e) {
      rethrow;
    }
  }
}
