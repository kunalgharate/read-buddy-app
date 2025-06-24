import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/domain/entities/app_user.dart';

@lazySingleton
class SecureStorageUtil {
  static final SecureStorageUtil _instance = SecureStorageUtil._internal();
  factory SecureStorageUtil() => _instance;
  SecureStorageUtil._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();


  Future<void> saveUser(AppUser appUser) async {
    final userJson = jsonEncode({
      '_id': appUser.id,
      'name': appUser.name,
      'email': appUser.email,
      'password': appUser.password,
      'role': appUser.role,
      'isPrime': appUser.isPrime,
      'finesDue': appUser.finesDue,
      'isEmailVerified': appUser.isEmailVerified,
      'badges': appUser.badges,
      'createdAt': appUser.createdAt.toIso8601String(),
      'updatedAt': appUser.updatedAt.toIso8601String(),
      '__v': appUser.version,
    });
    await _storage.write(key: "user", value: userJson);
  }

  Future<AppUser?> getUser() async {
    final jsonString = await _storage.read(key: "user");
    if (jsonString == null) return null;
    final Map<String, dynamic> userJson = jsonDecode(jsonString);


   final appUser=  AppUser(
     id: userJson['_id'] ?? '',
     name: userJson['name'] ?? '',
     email: userJson['email'] ?? '',
     password: userJson['password'] ?? '',
     role: userJson['role'] ?? '',
     isPrime: userJson['isPrime'] ?? false,
     finesDue: userJson['finesDue'] ?? 0,
     isEmailVerified: userJson['isEmailVerified'] ?? false,
     badges: userJson['badges'] ?? [],
     createdAt: DateTime.parse(userJson['createdAt']),
     updatedAt: DateTime.parse(userJson['updatedAt']),
     version: userJson['__v'] ?? 0,
     accessToken: userJson['accessToken'] ?? '',
     refreshToken: userJson['refreshToken'] ?? '',
    );

    return appUser;
  }

  /// Save any key-value pair securely
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Read value for a given key
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Delete a specific key
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Delete all keys
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Save tokens specifically
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: 'accessToken', value: accessToken);
    await write(key: 'refreshToken', value: refreshToken);
  }

  /// Get access token
  Future<String?> getAccessToken() async => read(key: 'accessToken');

  /// Get refresh token
  Future<String?> getRefreshToken() async => read(key: 'refreshToken');

  /// Clear tokens only
  Future<void> clearTokens() async {
    await delete(key: 'accessToken');
    await delete(key: 'refreshToken');
  }

  /// Get onboarding status
  Future<bool> getOnboardingStatus() async {
    final status = await read(key: 'onboardingStatus');
    return status == 'true';
  }

  /// Save onboarding status
  Future<void> saveOnboardingStatus(bool status) async {
    await write(key: 'onboardingStatus', value: status.toString());
  }
}
