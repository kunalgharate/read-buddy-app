// impddort 'package:read_buddy_app/features/banner/datasources/model/banner_model.dart';
import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

class BookResponseModel {
  final String id;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String duration;
  final String imageUrl;
  final String formatUrl;

  BookResponseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.duration,
    required this.imageUrl,
    required this.formatUrl,
  });

  factory BookResponseModel.fromJson(Map<String, dynamic> json) {
    return BookResponseModel(
      id: json['_id'] ?? '',
      title: json['title'],
      category: json['genre'] ?? 'General',
      donor: json['author'] ?? 'Unknown',
      format: json['format'] ?? 'Unknown',
      duration: '3 Days',
      imageUrl: json['coverImageUrl'] ?? 'assets/fiction.png',
      formatUrl: 'assets/fiction.png',
    );
  }

  RecommendedBookCardEntity toRecommendedEntity() {
    return RecommendedBookCardEntity(
      id: id,
      title: title,
      category: category,
      donor: donor,
      format: format,
      duration: duration,
      imageUrl: imageUrl,
      formatUrl: formatUrl,
    );
  }

  LatestBookEntity toLatestEntity() {
    return LatestBookEntity(
      id: id,
      title: title,
      category: category,
      donor: donor,
      format: format,
      duration: duration,
      imageUrl: imageUrl,
      formatUrl: formatUrl,
    );
  }
}

class StatModel {
  final String bookDonated;
  final String activeUsers;
  final String deleveries;
  StatModel({
    required this.bookDonated,
    required this.activeUsers,
    required this.deleveries,
  });
  factory StatModel.fromJson(Map<String, dynamic> json) {
    return StatModel(
      bookDonated: json['book_donated'],
      activeUsers: json['active_users'],
      deleveries: json['deliveries'],
    );
  }
  StatEntity toEntity() {
    return StatEntity(
      bookDonated: bookDonated,
      activeUsers: activeUsers,
      deleveries: deleveries,
    );
  }
}

class BannerModel extends BannerEntity {
  BannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
  });
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
  BannerEntity toEntity() => BannerEntity(
        id: id,
        title: title,
        imageUrl: imageUrl,
      );
}
