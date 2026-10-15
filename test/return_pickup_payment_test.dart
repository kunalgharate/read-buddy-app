import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/book_request/data/datasources/book_request_remote_datasource.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/book_detail_entity.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/book_request_entity.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/pickup_details_entity.dart';
import 'package:read_buddy_app/features/book_request/domain/repositories/book_request_repository.dart';
import 'package:read_buddy_app/features/book_request/domain/usecases/create_return_pickup_order.dart';
import 'package:read_buddy_app/features/book_request/domain/usecases/verify_return_pickup_payment.dart';

/// Minimal [HttpClientAdapter] stub so datasource tests can control the raw
/// HTTP response without pulling in a mocking package.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastOptions = options;
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int statusCode) => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

BookRequestRemoteDataSourceImpl _datasource(_StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return BookRequestRemoteDataSourceImpl(
    dio: dio,
    secureStorage: SecureStorageUtil(),
  );
}

void main() {
  setUpAll(() {
    AppConfig.init(
      environment: Environment.dev,
      baseUrl: 'https://example.test/api',
      appName: 'ReadBuddy',
    );
  });

  group('BookRequestRemoteDataSource.createReturnPickupOrder', () {
    test('parses a top-level order payload', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': true,
            'orderId': 'order_ABC123',
            'amount': 2500,
            'razorpayKey': 'rzp_test_123',
          }, 200));
      final ds = _datasource(adapter);

      final result = await ds.createReturnPickupOrder('req1');

      expect(adapter.lastOptions!.method, 'PATCH');
      expect(
        adapter.lastOptions!.uri.path,
        '/api/users/return-requests/req1/pickup/payment/create-order',
      );
      expect(result['orderId'], 'order_ABC123');
      expect(result['amount'], 2500);
      expect(result['razorpayKey'], 'rzp_test_123');
    });

    test('unwraps a nested data payload and key fallbacks', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': true,
            'data': {
              'order_id': 'order_NESTED',
              'amount': 2500,
              'razorpay_key': 'rzp_live_999',
            },
          }, 201));
      final ds = _datasource(adapter);

      final result = await ds.createReturnPickupOrder('req2');

      expect(result['orderId'], 'order_NESTED');
      expect(result['razorpayKey'], 'rzp_live_999');
    });

    test('throws a friendly error when no order id is returned', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': true,
            'amount': 2500,
          }, 200));
      final ds = _datasource(adapter);

      expect(
        () => ds.createReturnPickupOrder('req3'),
        throwsA(isA<Exception>()),
      );
    });

    test('surfaces the server message on a 4xx response', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': false,
            'message': 'Book must be delivered before returning',
          }, 400));
      final ds = _datasource(adapter);

      expect(
        () => ds.createReturnPickupOrder('req4'),
        throwsA(
          predicate(
            (e) => e is Exception &&
                e.toString().contains('Book must be delivered'),
          ),
        ),
      );
    });
  });

  group('BookRequestRemoteDataSource.verifyReturnPickupPayment', () {
    test('PATCHes the verify endpoint with the contract body', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': true,
            'message': 'Payment verified',
          }, 200));
      final ds = _datasource(adapter);

      await ds.verifyReturnPickupPayment(
        'req1',
        paymentId: 'pay_1',
        orderId: 'order_1',
        signature: 'sig_1',
        pickupAddress: 'Flat 12, MG Road',
      );

      expect(adapter.lastOptions!.method, 'PATCH');
      expect(
        adapter.lastOptions!.uri.path,
        '/api/users/return-requests/req1/pickup/payment/verify-payment',
      );
      expect(adapter.lastOptions!.data, {
        'paymentId': 'pay_1',
        'orderId': 'order_1',
        'signature': 'sig_1',
        'pickupAddress': 'Flat 12, MG Road',
      });
    });

    test('surfaces the server message on failure', () async {
      final adapter = _StubAdapter((_) async => _json({
            'success': false,
            'message': 'Invalid payment signature',
          }, 400));
      final ds = _datasource(adapter);

      expect(
        () => ds.verifyReturnPickupPayment(
          'req1',
          paymentId: 'pay_1',
          orderId: 'order_1',
          signature: 'bad',
          pickupAddress: 'addr',
        ),
        throwsA(
          predicate(
            (e) => e is Exception &&
                e.toString().contains('Invalid payment signature'),
          ),
        ),
      );
    });
  });

  group('Return pickup usecases forward to the repository', () {
    test('CreateReturnPickupOrderUsecase passes the request id', () async {
      final repo = _FakeRepo();
      final usecase = CreateReturnPickupOrderUsecase(repo);

      final result = await usecase('req-42');

      expect(repo.createdOrderFor, 'req-42');
      expect(result['orderId'], 'order_fake');
    });

    test('VerifyReturnPickupPaymentUsecase passes every argument', () async {
      final repo = _FakeRepo();
      final usecase = VerifyReturnPickupPaymentUsecase(repo);

      await usecase(
        'req-42',
        paymentId: 'pay_1',
        orderId: 'order_1',
        signature: 'sig_1',
        pickupAddress: 'addr',
      );

      expect(repo.verifiedFor, 'req-42');
      expect(repo.verifyArgs, {
        'paymentId': 'pay_1',
        'orderId': 'order_1',
        'signature': 'sig_1',
        'pickupAddress': 'addr',
      });
    });
  });

  group('api constants', () {
    test('build the pickup payment paths', () {
      expect(
        ApiConstants.returnRequestPickupPaymentCreateOrder('x'),
        endsWith('/users/return-requests/x/pickup/payment/create-order'),
      );
      expect(
        ApiConstants.returnRequestPickupPaymentVerify('x'),
        endsWith('/users/return-requests/x/pickup/payment/verify-payment'),
      );
    });
  });
}

class _FakeRepo implements BookRequestRepository {
  String? createdOrderFor;
  String? verifiedFor;
  Map<String, String>? verifyArgs;

  @override
  Future<Map<String, dynamic>> createReturnPickupOrder(String id) async {
    createdOrderFor = id;
    return {'orderId': 'order_fake', 'amount': 2500, 'razorpayKey': 'rzp_test'};
  }

  @override
  Future<void> verifyReturnPickupPayment(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
    required String pickupAddress,
  }) async {
    verifiedFor = id;
    verifyArgs = {
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'pickupAddress': pickupAddress,
    };
  }

  @override
  Future<void> acceptBookRequest(String id, {String? notes}) =>
      throw UnimplementedError();

  @override
  Future<void> cancelBookRequest(String id, String reason) =>
      throw UnimplementedError();

  @override
  Future<String> createBookRequest(
    String bookId,
    String fulfillmentMethod, {
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryPincode,
    String? deliveryPreferredDate,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> declineBookRequest(String id, {String reason = ''}) =>
      throw UnimplementedError();

  @override
  Future<List<BookRequestEntity>> getAllBookRequests() =>
      throw UnimplementedError();

  @override
  Future<BookDetailEntity> getBookById(String id) => throw UnimplementedError();

  @override
  Future<List<LibraryEntity>> getLibraryDetails() => throw UnimplementedError();

  @override
  Future<List<BookRequestEntity>> getMyBookRequests() =>
      throw UnimplementedError();

  @override
  Future<BookRequestEntity> getRequestDetails(String id) =>
      throw UnimplementedError();

  @override
  Future<List<BookRequestEntity>> getUpcomingPickups() =>
      throw UnimplementedError();

  @override
  Future<void> initiateReturn(
    String id, {
    required String returnMethod,
    String? returnBranchId,
    PickupDetailsEntity? pickup,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> scheduleDelivery(
    String id,
    String name,
    String phone,
    String address,
    String pincode,
    String preferredDate,
    String preferredTime,
  ) =>
      throw UnimplementedError();

  @override
  Future<BookRequestEntity> schedulePickup(PickupDetailsEntity details) =>
      throw UnimplementedError();

  @override
  Future<void> updateRequestStatus(String id, String status) =>
      throw UnimplementedError();
}
