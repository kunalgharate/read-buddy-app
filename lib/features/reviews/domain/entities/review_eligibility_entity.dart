import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';

class ReviewEligibilityEntity extends Equatable {
  final bool canReview;
  final bool hasBorrowed;
  final ReviewEntity? existingReview;

  const ReviewEligibilityEntity({
    required this.canReview,
    required this.hasBorrowed,
    this.existingReview,
  });

  @override
  List<Object?> get props => [canReview, hasBorrowed, existingReview];
}
