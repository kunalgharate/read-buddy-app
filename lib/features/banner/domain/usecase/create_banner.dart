import 'dart:io';

import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

class CreateBannerUsecase {
  final BannerRepository repository;

  CreateBannerUsecase(this.repository);

  Future<void> call({
    required String title,
    String? link,
    String? description,
    required String bannerType,
    required File bannerImage,
  }) {
    return repository.createBanner(
      title: title,
      link: link,
      description: description,
      bannerType: bannerType,
      bannerImage: bannerImage,
    );
  }
}
