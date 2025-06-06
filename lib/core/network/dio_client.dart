// core/network/dio_client.dart
import 'package:dio/dio.dart';

// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio => Dio(BaseOptions(baseUrl: 'http://readbuddy-server.onrender.com/api/'));
}
