import 'dart:io';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

enum ImageSource { camera, gallery }

@injectable
class ImagePickerService {
  final picker.ImagePicker _picker = picker.ImagePicker();

  /// Pick a single image from camera or gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      // Request permissions
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        throw Exception('Permission denied. Please grant ${source == ImageSource.camera ? 'camera' : 'gallery'} permission.');
      }

      // Pick image
      final picker.XFile? pickedFile = await _picker.pickImage(
        source: source == ImageSource.camera 
            ? picker.ImageSource.camera 
            : picker.ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  /// Request appropriate permissions based on source
  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      // For gallery access
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }
      return true; // Default to true for other platforms
    }
  }

  /// Check if permissions are already granted
  Future<bool> hasPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.isGranted;
    } else {
      if (Platform.isAndroid) {
        return await Permission.storage.isGranted;
      } else if (Platform.isIOS) {
        return await Permission.photos.isGranted;
      }
      return true;
    }
  }
}
