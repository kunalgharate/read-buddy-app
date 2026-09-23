import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../models/book_detail_model.dart';
import '../models/book_request_model.dart';
import '../models/library_model.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/entities/pickup_details_entity.dart';
import '../../domain/entities/request_payment_intent.dart';

abstract class BookRequestRemoteDataSource {
  Future<BookDetailModel> getBookById(String id);
  Future<String> createBookRequest(
    String bookId,
    String fulfillmentMethod, {
    String? libraryId,
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
  Future<LibraryEntity> getLibraryDetails({
    String? preferredLibraryId,
    double? userLat,
    double? userLng,
  });
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
    String preferredTime,
  );
  Future<void> initiateReturn(
    String id,
    String returnMethod, {
    String? returnBranchId,
  });

  /// Creates a ₹25 delivery-fee Razorpay order for an approved DELIVERY
  /// request. Returns { keyId, order, bookRequestId }.
  Future<Map<String, dynamic>> createDeliveryPaymentOrder(String id);

  /// Verifies the ₹25 delivery-fee payment (marks request PAID -> shipping).
  Future<void> verifyDeliveryPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
  });

  Future<RequestPaymentIntent> createBookRequestPayment(String id);
  Future<void> verifyBookRequestPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
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
    String? libraryId,
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
      // Persist the selected pickup library so it can be shown back to the
      // user in the request detail (Pickup Details) instead of defaulting to
      // some other/first library.
      if (method == 'PICKUP' && libraryId != null && libraryId.isNotEmpty) {
        body['libraryId'] = libraryId;
      }
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
        serverMsg ?? 'Failed to approve request. Please try again.',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> declineBookRequest(
    String id, {
    String reason = 'Request declined',
  }) async {
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
  Future<LibraryEntity> getLibraryDetails({
    String? preferredLibraryId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await dio.get(ApiConstants.libraryDetails);
      if (response.statusCode != ApiConstants.success) {
        throw Exception('Failed to load library details');
      }
      final decoded = response.data;

      // The endpoint returns { success, libraries: [...] }. Older callers
      // wrongly parsed the whole envelope as a single library, which produced
      // a blank/incorrect library card. Parse the list properly, then pick the
      // library that matches the request's saved libraryId; fall back to the
      // nearest (when coordinates are provided) and finally the first.
      final rawList = decoded is Map && decoded['libraries'] is List
          ? decoded['libraries'] as List
          : (decoded is Map && decoded['data'] is List
              ? decoded['data'] as List
              : const []);

      final libraries = rawList
          .whereType<Map>()
          .map((e) => LibraryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (libraries.isEmpty) {
        throw Exception('No libraries available');
      }

      // 1. Prefer the exact library saved on the request.
      if (preferredLibraryId != null && preferredLibraryId.isNotEmpty) {
        for (final lib in libraries) {
          if (lib.id == preferredLibraryId) return lib;
        }
      }

      // 2. Otherwise pick the nearest to the user (if location known),
      //    respecting the 15 km service radius. Libraries farther than 15 km
      //    are not surfaced for pickup/return drop-off.
      if (userLat != null && userLng != null) {
        LibraryEntity? nearest;
        double? nearestKm;
        for (final lib in libraries) {
          if (lib.address.latitude == 0 && lib.address.longitude == 0) {
            continue;
          }
          final km = LocationService.instance.calculateDistanceKm(
            userLat,
            userLng,
            lib.address.latitude,
            lib.address.longitude,
          );
          if (km <= 15.0 && (nearestKm == null || km < nearestKm)) {
            nearestKm = km;
            nearest = lib;
          }
        }
        if (nearest != null) return nearest;
      }

      // 3. Final fallback — first library.
      return libraries.first;
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
    String preferredTime,
  ) async {
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
        serverMsg ?? 'Failed to schedule delivery. Please try again.',
      );
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
          serverMsg ?? 'Book request not found or not eligible for pickup',
        );
      }
      if (statusCode == ApiConstants.badRequest) {
        throw Exception(
          serverMsg ?? 'Invalid pickup details. Please check your input.',
        );
      }
      throw Exception(
        serverMsg ?? 'Failed to schedule pickup. Please try again.',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> initiateReturn(
    String id,
    String returnMethod, {
    String? returnBranchId,
  }) async {
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

  @override
  Future<Map<String, dynamic>> createDeliveryPaymentOrder(String id) async {
    try {
      final response =
          await dio.post('${ApiConstants.v1BookRequests}/$id/payment');
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to create delivery payment order');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(serverMsg ?? 'Failed to create delivery payment order');
    }
  }

  @override
  Future<RequestPaymentIntent> createBookRequestPayment(String id) async {
    try {
      final response = await dio.post(ApiConstants.bookRequestPayment(id));
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to create payment');
      }
      final data = response.data;
      final Map order =
          data is Map && data['order'] is Map ? data['order'] as Map : const {};
      final amount = order['amount'];
      return RequestPaymentIntent(
        razorpayKey: data is Map ? (data['keyId'] as String? ?? '') : '',
        orderId: order['id'] as String? ?? '',
        amount: amount is num ? amount.toInt() : 0,
        currency: order['currency'] as String? ?? 'INR',
        bookRequestId:
            data is Map ? (data['bookRequestId'] as String? ?? id) : id,
      );
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(
        serverMsg ?? 'Failed to initiate payment. Please try again.',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyDeliveryPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.v1BookRequests}/$id/payment/verify',
        data: {
          'paymentId': paymentId,
          'orderId': orderId,
          'signature': signature,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Delivery payment verification failed');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(serverMsg ?? 'Delivery payment verification failed');
    }
  }

  @override
  Future<void> verifyBookRequestPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.bookRequestPaymentVerify(id),
        data: {
          'paymentId': paymentId,
          'orderId': orderId,
          'signature': signature,
        },
      );
      if (response.statusCode != ApiConstants.success &&
          response.statusCode != ApiConstants.created) {
        throw Exception('Failed to verify payment');
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
              as String?
          : null;
      throw Exception(
        serverMsg ?? 'Payment verification failed. Please try again.',
      );
    } catch (e) {
      rethrow;
    }
  }
}
