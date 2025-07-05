import 'dart:io';

abstract class BannerRepository {
  Future<void> createBanner({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });
}
