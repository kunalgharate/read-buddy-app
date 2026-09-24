import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    super.id,
    required super.bookId,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    required super.rating,
    super.title,
    required super.comment,
    super.helpfulCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // The user reference can arrive under 'user' (new contract) or 'userId'
    // (legacy). Either may be a String (ID) or a populated Map.
    final userData = json['user'] ?? json['userId'];
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

    // book reference: 'bookId' (legacy) or 'book' (new contract)
    final bookData = json['bookId'] ?? json['book'];
    String bookId = '';
    if (bookData is Map<String, dynamic>) {
      bookId = bookData['_id']?.toString() ?? '';
    } else if (bookData != null) {
      bookId = bookData.toString();
    }

    return ReviewModel(
      id: json['_id']?.toString(),
      bookId: bookId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: (json['rating'] is int)
          ? json['rating'] as int
          : (json['rating'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      // Backend field is 'review'; keep 'comment' as a legacy fallback.
      comment: json['review']?.toString() ?? json['comment']?.toString() ?? '',
      helpfulCount: (json['helpfulCount'] is int)
          ? json['helpfulCount'] as int
          : (json['helpfulCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'bookId': bookId,
      'rating': rating,
      'title': title,
      'review': comment,
    };
  }
}
