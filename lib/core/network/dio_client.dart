import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/services/storage_service.dart';
import '../utils/app_interceptor.dart';
import 'api_constants.dart';

@module
abstract class DioModule {
  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();
  @lazySingleton
  StorageService provideStorageService(FlutterSecureStorage storage) =>
      StorageService(secureStorage: storage);
  @Named('auth')
  @lazySingleton
  Dio provideAuthDio() {
    return Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }

  @lazySingleton
  AppInterceptor appInterceptor(
    FlutterSecureStorage storage,
    @Named('auth') Dio authDio,
  ) =>
      AppInterceptor(storage, authDio);

  @lazySingleton
  Dio dio(AppInterceptor interceptor) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.add(interceptor);

    // Add logging interceptor only in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          // Only log in debug mode and avoid sensitive data
          if (!obj.toString().contains('password') &&
              !obj.toString().contains('token')) {
            print(obj);
          }
        },
      ));
    }

    return dio;
  }
}
