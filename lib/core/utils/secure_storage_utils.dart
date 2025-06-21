import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtil {
  static final SecureStorageUtil _instance = SecureStorageUtil._internal();
  factory SecureStorageUtil() => _instance;
  SecureStorageUtil._internal();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

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
}
