import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  /// Picks multiple images from the gallery after handling permissions.
  static Future<List<XFile>?> pickMultipleImages() async {
    final permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      return await picker.pickMultiImage(); // ✅ Picks multiple
    } else {
      return null;
    }
  }

  bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && uri.hasScheme;
  }
}
