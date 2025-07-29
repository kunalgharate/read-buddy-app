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
  @override
  final String? id;
  const BannerModel({
    required this.title,
    this.link,
    this.description,
    required this.bannerType,
    required this.bannerImage,
    this.id,
  }) : super(
          title: title,
          link: link,
          description: description,
          bannerType: bannerType,
          bannerImage: bannerImage,
        );

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'],
      title: json['title'] ?? "title",
      link: json['link'],
      description: json['desc'],
      bannerType: json['bannerType'] ?? "bannerType",
      bannerImage: json['imageUrl'] ?? "bannerImage",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'title': title,
      'link': link,
      'description': description,
      'bannerType': bannerType,
      'bannerImage': bannerImage,
    };
  }
}
