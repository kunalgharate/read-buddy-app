import 'dart:io';

import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

class UpdateBannerUsecase {
  final BannerRepository repository;

  UpdateBannerUsecase(this.repository);

  Future<void> call({
    required String id,
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  }) {
    return repository.updateBanner(
      id: id,
      title: title,
      link: link,
      description: description,
      bannerType: bannerType,
      bannerImage: bannerImage,
    );
  }
}
