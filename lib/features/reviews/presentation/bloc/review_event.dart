part of 'review_bloc.dart';

sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

final class LoadBookReviews extends ReviewEvent {
  final String bookId;

  const LoadBookReviews(this.bookId);

  @override
  List<Object> get props => [bookId];
}

final class LoadReviewEligibility extends ReviewEvent {
  final String bookId;

  const LoadReviewEligibility(this.bookId);

  @override
  List<Object> get props => [bookId];
}

final class CreateReviewEvent extends ReviewEvent {
  final String bookId;
  final int rating;
  final String title;
  final String comment;

  const CreateReviewEvent({
    required this.bookId,
    required this.rating,
    required this.title,
    required this.comment,
  });

  @override
  List<Object> get props => [bookId, rating, title, comment];
}

final class UpdateReviewEvent extends ReviewEvent {
  final String id;
  final String bookId;
  final int rating;
  final String title;
  final String comment;

  const UpdateReviewEvent({
    required this.id,
    required this.bookId,
    required this.rating,
    required this.title,
    required this.comment,
  });

  @override
  List<Object> get props => [id, bookId, rating, title, comment];
}

final class DeleteReviewEvent extends ReviewEvent {
  final String id;
  final String bookId;

  const DeleteReviewEvent({
    required this.id,
    required this.bookId,
  });

  @override
  List<Object> get props => [id, bookId];
}
