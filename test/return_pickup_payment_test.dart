import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/book_request/data/datasources/book_request_remote_datasource.dart';
import 'package:read_buddy_app/features/book_request/domain/entities/pickup_details_entity.dart';

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

/// A stub that always answers with [body] and [statusCode].
_StubAdapter _stub(Map<String, dynamic> body, int statusCode) =>
    _StubAdapter((_) async => _json(body, statusCode));

BookRequestRemoteDataSourceImpl _datasource(_StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return BookRequestRemoteDataSourceImpl(
    dio: dio,
    secureStorage: SecureStorageUtil(),
  );
}

PickupDetailsEntity _pickup() => PickupDetailsEntity(
      requestId: 'req1',
      userName: 'Test User',
      phoneNumber: '9999999999',
      address: 'Flat 12, MG Road',
      pickupDate: DateTime(2026, 10, 20),
      pickupTime: '19:07',
    );

void main() {
  setUpAll(() {
    AppConfig.init(
      environment: Environment.dev,
      baseUrl: 'https://example.test/api',
      appName: 'ReadBuddy',
    );
  });

  group('BookRequestRemoteDataSource.initiateReturn', () {
    test('sends method, branch and an ISO-8601 return schedule', () async {
      final adapter =
          _stub({'success': true, 'message': 'Return initiated'}, 200);
      final ds = _datasource(adapter);

      await ds.initiateReturn(
        'req1',
        'DROP_OFF',
        returnBranchId: 'branch_9',
        pickup: _pickup(),
      );

      expect(adapter.lastOptions!.method, 'POST');
      expect(
        adapter.lastOptions!.uri.path,
        '/api/v1/book-requests/req1/initiate-return',
      );
      final data = adapter.lastOptions!.data as Map;
      expect(data['returnMethod'], 'DROP_OFF');
      expect(data['returnBranchId'], 'branch_9');
      expect(data['returnScheduledDate'], '2026-10-20T00:00:00.000');
      expect(data['returnScheduledSlot'], '07:07 PM');
    });

    test('omits blank branch and date fields when not provided', () async {
      final adapter = _stub({'success': true}, 200);
      final ds = _datasource(adapter);

      await ds.initiateReturn('req2', 'PICKUP', returnBranchId: '');

      final data = adapter.lastOptions!.data as Map;
      expect(data['returnMethod'], 'PICKUP');
      expect(data.containsKey('returnBranchId'), isFalse);
      expect(data.containsKey('returnScheduledDate'), isFalse);
      expect(data.containsKey('returnScheduledSlot'), isFalse);
    });

    test('surfaces the server message on a 4xx response', () async {
      final adapter = _stub(
        {'success': false, 'message': 'Book must be delivered'},
        400,
      );
      final ds = _datasource(adapter);

      expect(
        () => ds.initiateReturn('req3', 'DROP_OFF'),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Book must be delivered'),
          ),
        ),
      );
    });
  });

  group('BookRequestRemoteDataSource.createReturnPickupOrder', () {
    test('parses a top-level order payload', () async {
      final adapter = _stub(
        {
          'success': true,
          'orderId': 'order_ABC123',
          'amount': 2500,
          'razorpayKey': 'rzp_test_123',
        },
        200,
      );
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
      final adapter = _stub(
        {
          'success': true,
          'data': {
            'order_id': 'order_NESTED',
            'amount': 2500,
            'razorpay_key': 'rzp_live_999',
          },
        },
        201,
      );
      final ds = _datasource(adapter);

      final result = await ds.createReturnPickupOrder('req2');

      expect(result['orderId'], 'order_NESTED');
      expect(result['razorpayKey'], 'rzp_live_999');
    });

    test('accepts keyId as a last-resort fallback (delivery-fee naming)',
        () async {
      final adapter = _stub(
        {
          'success': true,
          'orderId': 'order_K1',
          'amount': 2500,
          'keyId': 'rzp_test_k1',
        },
        200,
      );
      final ds = _datasource(adapter);

      final result = await ds.createReturnPickupOrder('reqK');

      expect(result['orderId'], 'order_K1');
      expect(result['razorpayKey'], 'rzp_test_k1');
    });

    test('throws a friendly error when no order id is returned', () async {
      final adapter = _stub({'success': true, 'amount': 2500}, 200);
      final ds = _datasource(adapter);

      expect(
        () => ds.createReturnPickupOrder('req3'),
        throwsA(isA<Exception>()),
      );
    });

    test('surfaces the server message on a 4xx response', () async {
      final adapter = _stub(
        {'success': false, 'message': 'Book must be delivered'},
        400,
      );
      final ds = _datasource(adapter);

      expect(
        () => ds.createReturnPickupOrder('req4'),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Book must be delivered'),
          ),
        ),
      );
    });
  });

  group('BookRequestRemoteDataSource.verifyReturnPickupPayment', () {
    test('PATCHes the verify endpoint with the contract body', () async {
      final adapter =
          _stub({'success': true, 'message': 'Payment verified'}, 200);
      final ds = _datasource(adapter);

      await ds.verifyReturnPickupPayment(
        'req1',
        paymentId: 'pay_1',
        orderId: 'order_1',
        signature: 'sig_1',
        pickupAddress: 'Flat 12, MG Road',
        returnScheduledDate: '2026-10-20T00:00:00.000',
        returnScheduledSlot: '07:07 PM',
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
        'returnScheduledDate': '2026-10-20T00:00:00.000',
        'returnScheduledSlot': '07:07 PM',
      });
    });

    test('omits blank schedule fields', () async {
      final adapter = _stub({'success': true}, 200);
      final ds = _datasource(adapter);

      await ds.verifyReturnPickupPayment(
        'req1',
        paymentId: 'pay_1',
        orderId: 'order_1',
        signature: 'sig_1',
        pickupAddress: 'addr',
        returnScheduledDate: '',
        returnScheduledSlot: '',
      );

      final data = adapter.lastOptions!.data as Map;
      expect(data.containsKey('returnScheduledDate'), isFalse);
      expect(data.containsKey('returnScheduledSlot'), isFalse);
    });

    test('surfaces the server message on failure', () async {
      final adapter = _stub(
        {'success': false, 'message': 'Invalid payment signature'},
        400,
      );
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
            (e) =>
                e is Exception &&
                e.toString().contains('Invalid payment signature'),
          ),
        ),
      );
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
