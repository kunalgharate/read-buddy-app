part of 'review_bloc.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();
}

final class ReviewInitial extends ReviewState {
  @override
  List<Object> get props => [];
}

final class ReviewLoading extends ReviewState {
  @override
  List<Object> get props => [];
}

final class ReviewsLoaded extends ReviewState {
  final List<ReviewEntity> reviews;
  final double averageRating;
  final int totalReviews;
  final ReviewEligibilityEntity? eligibility;

  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    this.eligibility,
  });

  ReviewsLoaded copyWith({
    List<ReviewEntity>? reviews,
    double? averageRating,
    int? totalReviews,
    ReviewEligibilityEntity? eligibility,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      eligibility: eligibility ?? this.eligibility,
    );
  }

  @override
  List<Object?> get props =>
      [reviews, averageRating, totalReviews, eligibility];
}

/// Standalone eligibility result — used by entry points (e.g. the delivered
/// book request detail page) that only need to know whether a user can review.
final class ReviewEligibilityLoaded extends ReviewState {
  final ReviewEligibilityEntity eligibility;

  const ReviewEligibilityLoaded(this.eligibility);

  @override
  List<Object> get props => [eligibility];
}

final class ReviewActionSuccess extends ReviewState {
  final String message;

  const ReviewActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}
