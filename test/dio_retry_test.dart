import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/network/dio_client.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';

/// Adapter that behaves like a server dropping the first [failures] sockets.
class _DroppingAdapter implements HttpClientAdapter {
  _DroppingAdapter({this.failures = 2});

  final int failures;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls <= failures) {
      // This is what the Render/Cloudflare edge produces when it closes a
      // pooled keep-alive connection under the request.
      throw const SocketException('Connection reset by peer');
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('retries a GET when the connection is dropped mid-flight', () async {
    final dio = DioClient.createDio();
    final adapter = _DroppingAdapter(failures: 2);
    dio.httpClientAdapter = adapter;

    final response = await dio.get('http://127.0.0.1/ping');

    expect(response.statusCode, 200);
    expect(response.data, {'ok': true});
    expect(adapter.calls, 3, reason: 'two dropped connections, then the retry');
  });

  test('does not retry a POST when the connection is dropped', () async {
    final dio = DioClient.createDio();
    final adapter = _DroppingAdapter(failures: 99);
    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.post('http://127.0.0.1/create', data: {'a': 1}),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1, reason: 'POST retries could duplicate records');
  });

  test('reports a dropped connection as a readable message', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/v1/book-requests/my'),
      type: DioExceptionType.unknown,
      message: 'HttpException: Connection reset by peer',
    );

    expect(
      ErrorHandler.getErrorMessage(error),
      'The connection was interrupted. Please try again.',
    );
  });
}
