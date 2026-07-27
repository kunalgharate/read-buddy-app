import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  /// Picks multiple images from the gallery.
  /// On iOS 14+ and Android 13+, image_picker handles permissions internally
  /// via PHPicker / Photo Picker — no runtime permission request needed.
  static Future<List<XFile>?> pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();
      if (images.isNotEmpty) return images;
      return null;
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
