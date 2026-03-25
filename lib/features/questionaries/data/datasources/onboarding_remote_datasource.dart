// questionaries/data/datasources/onboarding_remote_datasource.dart
import 'package:dio/dio.dart';

import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import '../../../../core/network/api_constants.dart';
import '../models/question_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<QuestionModel>> getQuestions();
  Future<void> setPreferences(Map<String, dynamic> body);
  Future<void> updatePreferences(Map<String, dynamic> body);
  Future<void> deletePreferences();
  Future<void> setOnboardingStatus();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final Dio dio;
  final SecureStorageUtil secureStorage;

  OnboardingRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  Future<Options> get _authOptions async {
    final token = await secureStorage.getAccessToken() ?? '';
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<List<QuestionModel>> getQuestions() async {
    final response = await dio.get(
      ApiConstants.getAllQuestions,         // ← was hardcoded URL
      options: await _authOptions,
    );
    return (response.data as List)
        .map((q) => QuestionModel.fromJson(q))
        .toList();
  }

  @override
  Future<void> setPreferences(Map<String, dynamic> body) async {
    await dio.post(
      ApiConstants.setUserPreferences,      // ← was hardcoded URL
      data: body,
      options: await _authOptions,
    );
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> body) async {
    await dio.patch(
      ApiConstants.updateUserPreference,    // ← was hardcoded URL
      data: body,
      options: await _authOptions,
    );
  }

  @override
  Future<void> deletePreferences() async {
    await dio.delete(
      ApiConstants.resetUserPreference,     // ← was hardcoded URL
      options: await _authOptions,
    );
  }

  @override
  Future<void> setOnboardingStatus() async {
    await dio.put(
      ApiConstants.setOnboardingStatus,     // ← was hardcoded URL
      data: {'status': true},
      options: await _authOptions,
    );
  }
}