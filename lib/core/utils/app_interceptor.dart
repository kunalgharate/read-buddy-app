import 'package:dio/dio.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[DIO Request] => ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    print('Data: ${options.data}');
    handler.next(options); // continue
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[DIO Response] => ${response.statusCode} ${response.requestOptions.uri}');
    print('Response data: ${response.data}');
    handler.next(response); // continue
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[DIO Error] => ${err.type} ${err.message}');
    if (err.response != null) {
      print('Error response: ${err.response?.data}');
    }
    handler.next(err); // continue
  }
}
