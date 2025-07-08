import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera,
  gallery,
  location,
  internet,
  storage,
  notification,
}

class PermissionInfo {
  final AppPermission permission;
  final String title;
  final String description;
  final String icon;
  final bool isRequired;
  final bool isGranted;

  const PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    required this.isRequired,
    required this.isGranted,
  });

  PermissionInfo copyWith({
    AppPermission? permission,
    String? title,
    String? description,
    String? icon,
    bool? isRequired,
    bool? isGranted,
  }) {
    return PermissionInfo(
      permission: permission ?? this.permission,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isRequired: isRequired ?? this.isRequired,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}

@injectable
class PermissionService {
  
  /// Get all app permissions with their current status
  Future<List<PermissionInfo>> getAllPermissions() async {
    final permissions = [
      PermissionInfo(
        permission: AppPermission.camera,
        title: 'Camera',
        description: 'Take photos for profile picture and book covers',
        icon: '📷',
        isRequired: true,
        isGranted: await Permission.camera.isGranted,
      ),
      PermissionInfo(
        permission: AppPermission.gallery,
        title: 'Photo Library',
        description: 'Select images from your photo library',
        icon: '🖼️',
        isRequired: true,
        isGranted: await _getGalleryPermissionStatus(),
      ),
      PermissionInfo(
        permission: AppPermission.location,
        title: 'Location',
        description: 'Find nearby books and set your location',
        icon: '📍',
        isRequired: true,
        isGranted: await Permission.location.isGranted,
      ),
      PermissionInfo(
        permission: AppPermission.storage,
        title: 'Storage',
        description: 'Save and access app data on your device',
        icon: '💾',
        isRequired: true,
        isGranted: await _getStoragePermissionStatus(),
      ),
      PermissionInfo(
        permission: AppPermission.notification,
        title: 'Notifications',
        description: 'Get updates about book requests and messages',
        icon: '🔔',
        isRequired: false,
        isGranted: await Permission.notification.isGranted,
      ),
      PermissionInfo(
        permission: AppPermission.internet,
        title: 'Internet Access',
        description: 'Connect to our servers and sync your data',
        icon: '🌐',
        isRequired: true,
        isGranted: true, // Internet permission is automatically granted
      ),
    ];

    return permissions;
  }

  /// Check if all required permissions are granted
  Future<bool> areAllRequiredPermissionsGranted() async {
    final permissions = await getAllPermissions();
    return permissions
        .where((p) => p.isRequired)
        .every((p) => p.isGranted);
  }

  /// Request a specific permission
  Future<bool> requestPermission(AppPermission appPermission) async {
    try {
      Permission permission;
      
      switch (appPermission) {
        case AppPermission.camera:
          permission = Permission.camera;
          break;
        case AppPermission.gallery:
          permission = _getGalleryPermission();
          break;
        case AppPermission.location:
          permission = Permission.location;
          break;
        case AppPermission.storage:
          permission = _getStoragePermission();
          break;
        case AppPermission.notification:
          permission = Permission.notification;
          break;
        case AppPermission.internet:
          return true; // Internet is automatically granted
      }

      final status = await permission.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  /// Request all required permissions
  Future<Map<AppPermission, bool>> requestAllRequiredPermissions() async {
    final results = <AppPermission, bool>{};
    
    final requiredPermissions = [
      AppPermission.camera,
      AppPermission.gallery,
      AppPermission.location,
      AppPermission.storage,
    ];

    for (final appPermission in requiredPermissions) {
      results[appPermission] = await requestPermission(appPermission);
    }

    return results;
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(AppPermission appPermission) async {
    Permission permission;
    
    switch (appPermission) {
      case AppPermission.camera:
        permission = Permission.camera;
        break;
      case AppPermission.gallery:
        permission = _getGalleryPermission();
        break;
      case AppPermission.location:
        permission = Permission.location;
        break;
      case AppPermission.storage:
        permission = _getStoragePermission();
        break;
      case AppPermission.notification:
        permission = Permission.notification;
        break;
      case AppPermission.internet:
        return false;
    }

    return await permission.isPermanentlyDenied;
  }

  /// Open app settings
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get platform-specific gallery permission
  Permission _getGalleryPermission() {
    if (Platform.isAndroid) {
      return Permission.storage;
    } else if (Platform.isIOS) {
      return Permission.photos;
    }
    return Permission.storage;
  }

  /// Get platform-specific storage permission
  Permission _getStoragePermission() {
    if (Platform.isAndroid) {
      return Permission.storage;
    }
    return Permission.storage;
  }

  /// Get gallery permission status
  Future<bool> _getGalleryPermissionStatus() async {
    if (Platform.isAndroid) {
      return await Permission.storage.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  /// Get storage permission status
  Future<bool> _getStoragePermissionStatus() async {
    if (Platform.isAndroid) {
      return await Permission.storage.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app data
  }
}
