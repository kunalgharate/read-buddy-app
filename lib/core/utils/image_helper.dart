import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  /// Picks multiple images from the gallery after handling permissions.
  static Future<List<XFile>?> pickMultipleImages() async {
    // On iOS 14+ and Android 13+, the image_picker plugin handles permissions
    // internally via PHPicker / Photo Picker. Only request Permission.photos
    // on older Android versions.
    bool hasPermission = true;

    if (Platform.isAndroid) {
      // Android 13+ (API 33) uses READ_MEDIA_IMAGES, older uses storage
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // Fallback: try storage permission for older Android
        final storageStatus = await Permission.storage.request();
        hasPermission = storageStatus.isGranted;
      }
    }
    // On iOS, image_picker handles permissions internally

    if (hasPermission) {
      try {
        final picker = ImagePicker();
        return await picker.pickMultiImage();
      } catch (e) {
        // Fallback to single image if multi-pick fails
        try {
          final picker = ImagePicker();
          final image = await picker.pickImage(source: ImageSource.gallery);
          if (image != null) return [image];
        } catch (_) {
          return null;
        }
        return null;
      }
    } else {
      return null;
    }
  }

  /// Picks a single image from the given source.
  static Future<XFile?> pickSingleImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(source: source);
    } catch (e) {
      return null;
    }
  }

  bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && uri.hasScheme;
  }
}
