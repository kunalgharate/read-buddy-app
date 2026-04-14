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

  // ─── User ────────────────────────────────────────────────────────────────

  Future<void> saveUser(AppUser appUser) async {
    final userJson = jsonEncode({
      '_id': appUser.id,
      'name': appUser.name,
      'email': appUser.email,
      'gender': appUser.gender,
      'phno': appUser.phno,
      'picture': appUser.picture,
      'password': appUser.password,
      'role': appUser.role,
      'isPrime': appUser.isPrime,
      'finesDue': appUser.finesDue,
      'isEmailVerified': appUser.isEmailVerified,
      'onboardingCompleted': appUser.onboardingCompleted, // ← ADDED
      'badges': appUser.badges,
      'wishlist': appUser.wishlist,
      'createdAt': appUser.createdAt.toIso8601String(),
      'updatedAt': appUser.updatedAt.toIso8601String(),
      '__v': appUser.version,
      'accessToken': appUser.accessToken, // ← ADDED
      'refreshToken': appUser.refreshToken, // ← ADDED
    });
    await _storage.write(key: 'user', value: userJson);
  }

  Future<AppUser?> getUser() async {
    final jsonString = await _storage.read(key: 'user');
    if (jsonString == null) return null;

    final Map<String, dynamic> u = jsonDecode(jsonString);

    return AppUser(
      id: u['_id'] ?? '',
      name: u['name'] ?? '',
      email: u['email'] ?? '',
      phno: u['phno'] ?? '',
      gender: u['gender'] ?? '',
      picture: u['picture'],
      password: u['password'] ?? '',
      role: u['role'] ?? '',
      isPrime: u['isPrime'] ?? false,
      finesDue: u['finesDue'] ?? 0,
      isEmailVerified: u['isEmailVerified'] ?? false,
      onboardingCompleted: u['onboardingCompleted'] ?? false, // ← ADDED
      badges: u['badges'] ?? [],
      wishlist: u['wishlist'] ?? [],
      createdAt: DateTime.parse(u['createdAt']),
      updatedAt: DateTime.parse(u['updatedAt']),
      version: u['__v'] ?? 0,
      accessToken: u['accessToken'] ?? '', // ← FIXED
      refreshToken: u['refreshToken'] ?? '', // ← FIXED
    );
  }

  // ─── Tokens ───────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: 'accessToken', value: accessToken);
    await write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getAccessToken() async => read(key: 'accessToken');
  Future<String?> getRefreshToken() async => read(key: 'refreshToken');
  Future<void> clearTokens() async {
    await delete(key: 'accessToken');
    await delete(key: 'refreshToken');
  }

  // ─── Onboarding status ────────────────────────────────────────────────────

  Future<bool> getOnboardingStatus() async {
    final status = await read(key: 'onboardingStatus');
    return status == 'true';
  }

  Future<void> saveOnboardingStatus(bool status) async {
    await write(key: 'onboardingStatus', value: status.toString());
  }
// ─── Forgot Password Session ──────────────────────────────────────────────

  Future<void> saveForgotPasswordSession({
    required String email,
    String? code,
  }) async {
    await write(key: 'fp_email', value: email);
    if (code != null) await write(key: 'fp_code', value: code);
  }

  Future<Map<String, String?>> getForgotPasswordSession() async {
    return {
      'email': await read(key: 'fp_email'),
      'code': await read(key: 'fp_code'),
    };
  }

  Future<void> clearForgotPasswordSession() async {
    await delete(key: 'fp_email');
    await delete(key: 'fp_code');
  }
  // ─── Generic ──────────────────────────────────────────────────────────────

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
