import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';

class BannerModel extends BannerEntity {
  @override
  final String title;
  @override
  final String? link;
  @override
  final String? description;
  @override
  final String bannerType;
  @override
  final String bannerImage;

  const BannerModel({
    required this.title,
    this.link,
    this.description,
    required this.bannerType,
    required this.bannerImage,
  }) : super(
          title: title,
          link: link,
          description: description,
          bannerType: bannerType,
          bannerImage: bannerImage,
        );

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'] ?? "title",
      link: json['link'],
      description: json['description'],
      bannerType: json['bannerType'] ?? "bannerType",
      bannerImage: json['bannerImage'] ?? "bannerImage",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'description': description,
      'bannerType': bannerType,
      'bannerImage': bannerImage,
    };
  }
}
