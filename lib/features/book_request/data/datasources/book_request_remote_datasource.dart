import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/error_handler.dart';
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
  Future<List<LibraryEntity>> getLibraryDetails();
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
  Future<void> initiateReturn(
    String id, {
    required String returnMethod,
    String? returnBranchId,
    PickupDetailsEntity? pickup,
  });
  Future<Map<String, dynamic>> createReturnPickupOrder(String id);
  Future<void> verifyReturnPickupPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
    required String pickupAddress,
  });
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
      // Normalize the caller's fulfillment method to the backend enum
      // (['DELIVERY', 'PICKUP', 'MEETUP']). The UI sends 'pickup'/'dropoff'.
      // Only known values are accepted; anything else is rejected rather than
      // silently coerced to PICKUP.
      final normalized = fulfillmentMethod.trim().toUpperCase();
      final String method;
      switch (normalized) {
        case 'PICKUP':
          method = 'PICKUP';
          break;
        case 'DROPOFF':
        case 'DROP_OFF':
        case 'DELIVERY':
          method = 'DELIVERY';
          break;
        case 'MEETUP':
          method = 'MEETUP';
          break;
        default:
          throw ArgumentError(
            'Unsupported fulfillment method: $fulfillmentMethod',
          );
      }

      final body = <String, dynamic>{
        'bookId': bookId,
        'fulfillmentMethod': method,
      };
      // Backend stores `address` only for DELIVERY; forward the user's
      // delivery address so it is not silently dropped.
      if (method == 'DELIVERY' && deliveryAddress != null) {
        body['address'] = deliveryAddress;
      }
      if (deliveryName != null) body['deliveryName'] = deliveryName;
      if (deliveryPhone != null) body['deliveryPhone'] = deliveryPhone;
      if (deliveryAddress != null) body['deliveryAddress'] = deliveryAddress;
      if (deliveryPincode != null) body['deliveryPincode'] = deliveryPincode;
      if (deliveryPreferredDate != null) {
        body['deliveryPreferredDate'] = deliveryPreferredDate;
      }

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
          : decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : <String, dynamic>{};
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
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(
          serverMsg ?? 'Failed to approve request. Please try again.');
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
  Future<List<LibraryEntity>> getLibraryDetails() async {
    try {
      final response = await dio.get(ApiConstants.libraryDetails);
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load library details');
      }
      final decoded = response.data;
      // The endpoint returns { success, libraries: [...] } — a list, not a
      // single library object, so parse every entry.
      final list = decoded is Map && decoded['libraries'] is List
          ? decoded['libraries'] as List
          : const [];
      return list
          .whereType<Map>()
          .map((e) => LibraryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
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
          : decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : <String, dynamic>{};
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
      final dateStr = _formatDate(details.pickupDate);
      final timeStr12 = _format12hTime(details.pickupTime);

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
          : responseData is Map
              ? Map<String, dynamic>.from(responseData)
              : <String, dynamic>{};
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
  Future<void> initiateReturn(
    String id, {
    required String returnMethod,
    String? returnBranchId,
    PickupDetailsEntity? pickup,
  }) async {
    // initiate-return only reads returnMethod, returnBranchId (DROP_OFF) and
    // the return schedule (returnScheduledDate/Slot); contact fields belong to
    // the borrow-side schedule-pickup endpoint and are ignored here, so don't
    // send them. returnScheduledDate is a Date/date-time on the backend — send
    // a full ISO-8601 value rather than a bare YYYY-MM-DD.
    final scheduledDate = pickup == null
        ? null
        : DateTime(pickup.pickupDate.year, pickup.pickupDate.month,
                pickup.pickupDate.day)
            .toIso8601String();
    final scheduledSlot =
        pickup == null ? null : _format12hTime(pickup.pickupTime);

    try {
      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/$id/initiate-return',
        data: {
          'returnMethod': returnMethod,
          if (returnBranchId != null && returnBranchId.isNotEmpty)
            'returnBranchId': returnBranchId,
          if (scheduledDate != null) 'returnScheduledDate': scheduledDate,
          if (scheduledSlot != null) 'returnScheduledSlot': scheduledSlot,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to initiate return');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error']) as String?
          : null;
      throw Exception(serverMsg ?? ErrorHandler.getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createReturnPickupOrder(String id) async {
    // PICKUP returns are paid (home collection). The backend creates the
    // Razorpay order and returns the order id + amount (paise) + checkout key.
    // create-order requires the request to still be `delivered`, so it must be
    // called *before* any initiate-return/verify call flips the status.
    try {
      final response = await dio.patch(
        ApiConstants.returnRequestPickupPaymentCreateOrder(id),
      );
      final status = response.statusCode ?? 0;
      if (status != ApiConstants.success && status != ApiConstants.created) {
        throw Exception('Failed to create return pickup payment order');
      }
      final raw = response.data;
      final root =
          raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      final orderId =
          (payload['orderId'] ?? payload['order_id'] ?? payload['id'])
              ?.toString();
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Payment order was not created. Please try again.');
      }
      final razorpayKey =
          (payload['razorpayKey'] ?? payload['razorpay_key'] ?? payload['key'])
              ?.toString();
      return {
        'orderId': orderId,
        'amount': payload['amount'],
        'razorpayKey': razorpayKey,
      };
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error']) as String?
          : null;
      throw Exception(serverMsg ?? ErrorHandler.getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyReturnPickupPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
    required String pickupAddress,
  }) async {
    try {
      final response = await dio.patch(
        ApiConstants.returnRequestPickupPaymentVerify(id),
        data: {
          'paymentId': paymentId,
          'orderId': orderId,
          'signature': signature,
          'pickupAddress': pickupAddress,
        },
      );
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to verify return pickup payment');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error']) as String?
          : null;
      throw Exception(serverMsg ?? ErrorHandler.getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Converts a 24-hour "HH:mm" string into "hh:mm AM/PM" — the format the
  /// schedule-pickup endpoint already accepts and stores.
  String _format12hTime(String time24) {
    final timeParts = time24.split(':');
    final hour24 = int.tryParse(timeParts[0]) ?? 0;
    final minute = timeParts.length > 1 ? timeParts[1] : '00';
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 =
        hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}
