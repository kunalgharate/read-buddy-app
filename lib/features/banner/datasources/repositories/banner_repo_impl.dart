import 'dart:io';

import 'package:read_buddy_app/features/banner/datasources/data/createbanner_remote_datasource.dart';
import 'package:read_buddy_app/features/banner/domain/repository/banner_repository.dart';

class BannerRepoImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepoImpl({required this.remoteDataSource});

  @override
  Future<void> createBanner(
      {required String title,
      String? link,
      String? description,
      required String bannerType,
      required File bannerImage}) {
    return remoteDataSource.createBanner(
        title: title,
        link: link,
        description: description,
        bannerType: bannerType,
        bannerImage: bannerImage);
  }
}
