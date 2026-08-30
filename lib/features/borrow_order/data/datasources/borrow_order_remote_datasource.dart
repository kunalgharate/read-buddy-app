import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../../domain/entities/borrow_order_entity.dart';
import '../models/borrow_order_model.dart';

abstract class BorrowOrderRemoteDataSource {
  Future<BorrowOrderModel> getMyDraft();
  Future<BorrowOrderModel> addBook(String bookId);
  Future<BorrowOrderModel> removeBook(String bookRequestId);
  Future<BorrowOrderModel> submitOrder({
    required FulfillmentMethod fulfillmentMethod,
    String? address,
    String? libraryId,
  });
  Future<List<BorrowOrderModel>> getMyOrders();
  Future<BorrowOrderModel> cancelOrder(String orderId, {String? note});
  Future<Map<String, dynamic>> createPayment(String orderId);
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  });
}

class BorrowOrderRemoteDataSourceImpl implements BorrowOrderRemoteDataSource {
  final Dio _dio;

  BorrowOrderRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  String get _baseEndpoint => '${ApiConstants.baseUrl}/v1/borrow-orders';

  /// Safely unwrap a `{ data: {...} }` envelope (or a bare object) into a Map.
  /// Throws a descriptive error if the payload is null/malformed instead of
  /// letting a raw cast crash.
  Map<String, dynamic> _unwrapOrder(dynamic data) {
    final raw = data is Map && data.containsKey('data') ? data['data'] : data;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    throw Exception('Unexpected or empty order response from server');
  }

  @override
  Future<BorrowOrderModel> getMyDraft() async {
    final response = await _dio.get('$_baseEndpoint/my-draft');
    return BorrowOrderModel.fromJson(_unwrapOrder(response.data));
  }

  @override
  Future<BorrowOrderModel> addBook(String bookId) async {
    final response = await _dio.post(
      '$_baseEndpoint/add-book',
      data: {'bookId': bookId},
    );
    return BorrowOrderModel.fromJson(_unwrapOrder(response.data));
  }

  @override
  Future<BorrowOrderModel> removeBook(String bookRequestId) async {
    final response = await _dio.delete(
      '$_baseEndpoint/remove-book/$bookRequestId',
    );
    return BorrowOrderModel.fromJson(_unwrapOrder(response.data));
  }

  @override
  Future<BorrowOrderModel> submitOrder({
    required FulfillmentMethod fulfillmentMethod,
    String? address,
    String? libraryId,
  }) async {
    final body = <String, dynamic>{
      'fulfillmentMethod': fulfillmentMethod.name,
    };
    if (address != null) body['address'] = address;
    if (libraryId != null) body['libraryId'] = libraryId;

    final response = await _dio.post('$_baseEndpoint/submit', data: body);
    return BorrowOrderModel.fromJson(_unwrapOrder(response.data));
  }

  @override
  Future<List<BorrowOrderModel>> getMyOrders() async {
    final response = await _dio.get('$_baseEndpoint/my-orders');
    final data = response.data;

    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list
        .whereType<Map>()
        .map((json) =>
            BorrowOrderModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<BorrowOrderModel> cancelOrder(String orderId, {String? note}) async {
    final body = <String, dynamic>{};
    if (note != null) body['note'] = note;

    final response = await _dio.patch(
      '$_baseEndpoint/$orderId/cancel',
      data: body,
    );
    return BorrowOrderModel.fromJson(_unwrapOrder(response.data));
  }

  @override
  Future<Map<String, dynamic>> createPayment(String orderId) async {
    final response = await _dio.post('$_baseEndpoint/$orderId/payment');
    final data = response.data;

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  @override
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  }) async {
    await _dio.post(
      '$_baseEndpoint/$orderId/payment/verify',
      data: {
        'paymentId': paymentId,
        'orderId': razorpayOrderId,
        'signature': signature,
      },
    );
  }
}
