// core/network/dio_client.dart
import 'package:dio/dio.dart';

// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_interceptor.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @Named('auth')
  @lazySingleton
  Dio provideAuthDio() => Dio(); // clean Dio for refresh only

  @lazySingleton
  AppInterceptor appInterceptor(
      FlutterSecureStorage storage,
      @Named('auth') Dio authDio,
      ) => AppInterceptor(storage, authDio);

  @lazySingleton
  Dio dio(AppInterceptor interceptor) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://readbuddy-server.onrender.com/api/',
      followRedirects: true,
    ));

    dio.interceptors.add(interceptor);
    return dio;
  }
}
