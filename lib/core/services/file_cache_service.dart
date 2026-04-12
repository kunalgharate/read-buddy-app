import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// Caches remote files locally so they load instantly on repeat visits.
class FileCacheService {
  FileCacheService._();
  static final FileCacheService instance = FileCacheService._();

  final Dio _dio = Dio();
  Directory? _cacheDir;

  Future<Directory> get _dir async {
    _cacheDir ??= await getApplicationCacheDirectory();
    final dir = Directory('${_cacheDir!.path}/readbuddy_files');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Returns a local File for the given URL.
  /// Downloads if not cached, returns cached file if available.
  Future<File> getFile(String url) async {
    final dir = await _dir;
    final fileName = _hashUrl(url);
    final file = File('${dir.path}/$fileName');

    if (file.existsSync()) {
      if (kDebugMode) print('📁 Cache HIT: $url');
      return file;
    }

    if (kDebugMode) print('📁 Cache MISS, downloading: $url');
    await _dio.download(url, file.path);
    return file;
  }

  /// Returns local file path if cached, null otherwise.
  String? getCachedPath(String url) {
    if (_cacheDir == null) return null;
    final file = File('${_cacheDir!.path}/readbuddy_files/${_hashUrl(url)}');
    return file.existsSync() ? file.path : null;
  }

  /// Pre-download a file in background (for prefetching next track etc.)
  Future<void> prefetch(String url) async {
    try {
      await getFile(url);
    } catch (e) {
      if (kDebugMode) print('📁 Prefetch failed: $e');
    }
  }

  String _hashUrl(String url) {
    final bytes = utf8.encode(url);
    final hash = md5.convert(bytes).toString();
    final ext = url.split('.').last.split('?').first;
    return '$hash.$ext';
  }

  /// Clear all cached files
  Future<void> clearCache() async {
    final dir = await _dir;
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
