import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String title;
  final String? link;
  final String? description;
  final String bannerType;
  final String bannerImage;

  const BannerEntity({
    required this.title,
    this.link,
    this.description,
    required this.bannerType,
    required this.bannerImage,
  });

  @override
  List<Object?> get props =>
      [title, link, description, bannerType, bannerImage];
}
