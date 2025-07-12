import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

class BookResponseModel {
  final String title;
  final String category;
  final String donor;
  final String format;
  final String duration;
  final String imageUrl;
  final String formatUrl;

  BookResponseModel({
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.duration,
    required this.imageUrl,
    required this.formatUrl,
  });

  // factory BookResponseModel.fromJson(Map<String, dynamic> json) {
  //   return BookResponseModel(
  //     title: json['title'],
  //     category: json['category'],
  //     donor: json['donor'],
  //     format: json['format'],
  //     duration: json['duration'],
  //     imageUrl: json['image_url'],
  //     formatUrl: json['format_url'],
  //   );
  // }
  factory BookResponseModel.fromJson(Map<String, dynamic> json) {
    return BookResponseModel(
      title: json['name'],
      category: json['genre'],
      donor: json['donor_name'],
      format: json['book_format'],
      duration: json['duration_text'],
      imageUrl: json['image_url'],
      formatUrl: json['format_icon'],
    );
  }

  RecommendedBookCardEntity toRecommendedEntity() {
    return RecommendedBookCardEntity(
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
