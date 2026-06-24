import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.title,
    super.link,
    super.description,
    required super.bannerType,
    required super.bannerImage,
    super.id,
  });

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
