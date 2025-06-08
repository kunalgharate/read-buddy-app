// core/network/dio_client.dart
import 'package:dio/dio.dart';

// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_interceptor.dart';

@module
abstract class DioModule {

  @lazySingleton
  Dio dio(AppInterceptor interceptor) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://readbuddy-server.onrender.com/api/',
      followRedirects: true,
    ));

    dio.interceptors.add(interceptor);
    return dio;
  }

  @lazySingleton
  AppInterceptor appInterceptor() => AppInterceptor();
}

