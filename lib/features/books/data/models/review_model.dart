import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.reviewerName,
    required super.reviewerImageUrl,
    required super.rating,
    required super.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String? ?? '',
      reviewerName: json['userId']?['name'] as String? ?? 'Anonymous',
      reviewerImageUrl: json['reviewerImageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['review'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'reviewerName': reviewerName,
        'reviewerImageUrl': reviewerImageUrl,
        'rating': rating,
        'comment': comment,
      };
  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      reviewerName: reviewerName,
      reviewerImageUrl: reviewerImageUrl,
      rating: rating,
      comment: comment,
    );
  }
}
