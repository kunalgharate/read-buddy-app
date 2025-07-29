import 'dart:io';

import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';

abstract class BannerRepository {
  Future<List<BannerEntity>> getBannerList();

  Future<void> createBanner({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });

  Future<void> updateBanner({
    required String id,
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  });

  Future<void> deleteBanner({
    required String id,
  });
}
