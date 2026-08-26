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

  @override
  Future<BorrowOrderModel> getMyDraft() async {
    final response = await _dio.get('$_baseEndpoint/my-draft');
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return BorrowOrderModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<BorrowOrderModel> addBook(String bookId) async {
    final response = await _dio.post(
      '$_baseEndpoint/add-book',
      data: {'bookId': bookId},
    );
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return BorrowOrderModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<BorrowOrderModel> removeBook(String bookRequestId) async {
    final response = await _dio.delete(
      '$_baseEndpoint/remove-book/$bookRequestId',
    );
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return BorrowOrderModel.fromJson(json as Map<String, dynamic>);
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
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return BorrowOrderModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<BorrowOrderModel>> getMyOrders() async {
    final response = await _dio.get('$_baseEndpoint/my-orders');
    final data = response.data;

    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else {
      list = [];
    }

    return list
        .map((json) => BorrowOrderModel.fromJson(json as Map<String, dynamic>))
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
    final data = response.data;

    final json = data is Map && data.containsKey('data')
        ? data['data']
        : data;
    return BorrowOrderModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> createPayment(String orderId) async {
    final response = await _dio.post('$_baseEndpoint/$orderId/payment');
    final data = response.data;

    if (data is Map && data.containsKey('data')) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return Map<String, dynamic>.from(data as Map);
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
