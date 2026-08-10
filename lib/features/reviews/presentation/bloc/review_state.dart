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

  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object> get props => [reviews, averageRating, totalReviews];
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
