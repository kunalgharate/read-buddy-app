import 'package:read_buddy_app/features/reviews/data/models/review_model.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';

class ReviewEligibilityModel extends ReviewEligibilityEntity {
  const ReviewEligibilityModel({
    required super.canReview,
    required super.hasBorrowed,
    super.existingReview,
  });

  factory ReviewEligibilityModel.fromJson(Map<String, dynamic> json) {
    final existing = json['existingReview'];
    return ReviewEligibilityModel(
      canReview: json['canReview'] == true,
      hasBorrowed: json['hasBorrowed'] == true,
      existingReview: (existing is Map<String, dynamic>)
          ? ReviewModel.fromJson(existing)
          : null,
    );
  }
}
