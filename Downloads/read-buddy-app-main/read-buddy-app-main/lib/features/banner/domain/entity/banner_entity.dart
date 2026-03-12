import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String? id;
  final String title;
  final String? link;
  final String? description;
  final String bannerType;
  final String bannerImage;

  const BannerEntity({
    this.id,
    required this.title,
    this.link,
    this.description,
    required this.bannerType,
    required this.bannerImage,
  });

  @override
  List<Object?> get props =>
      [id, title, link, description, bannerType, bannerImage];
}
