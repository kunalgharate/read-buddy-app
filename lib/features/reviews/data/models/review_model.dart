import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    super.id,
    required super.bookId,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // userId can be a String (ID) or Map (populated object with _id, name, userAvatar)
    final userData = json['userId'];
    String userId = '';
    String userName = '';
    String userAvatar = '';

    if (userData is Map<String, dynamic>) {
      userId = userData['_id']?.toString() ?? '';
      userName = userData['name']?.toString() ?? '';
      userAvatar = userData['userAvatar']?.toString() ?? '';
    } else if (userData is String) {
      userId = userData;
    }

    // Fallback: some responses have user fields at root level
    if (userName.isEmpty) {
      userName = json['userName']?.toString() ?? '';
    }
    if (userAvatar.isEmpty) {
      userAvatar = json['userAvatar']?.toString() ?? '';
    }

    return ReviewModel(
      id: json['_id']?.toString(),
      bookId: json['bookId']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: (json['rating'] is int)
          ? json['rating'] as int
          : (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'bookId': bookId,
      'rating': rating,
      'comment': comment,
    };
  }
}
