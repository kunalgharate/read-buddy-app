import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/domain/repositories/review_repository.dart';
import 'package:read_buddy_app/features/reviews/domain/usecases/get_book_reviews.dart';
import 'package:read_buddy_app/features/reviews/domain/usecases/get_review_eligibility.dart';
import 'package:read_buddy_app/features/reviews/domain/usecases/create_review.dart';
import 'package:read_buddy_app/features/reviews/domain/usecases/update_review.dart';
import 'package:read_buddy_app/features/reviews/domain/usecases/delete_review.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetBookReviews _getBookReviews;
  final GetReviewEligibility _getReviewEligibility;
  final CreateReview _createReview;
  final UpdateReview _updateReview;
  final DeleteReview _deleteReview;

  ReviewBloc({
    required GetBookReviews getBookReviews,
    required GetReviewEligibility getReviewEligibility,
    required CreateReview createReview,
    required UpdateReview updateReview,
    required DeleteReview deleteReview,
  })  : _getBookReviews = getBookReviews,
        _getReviewEligibility = getReviewEligibility,
        _createReview = createReview,
        _updateReview = updateReview,
        _deleteReview = deleteReview,
        super(ReviewInitial()) {
    on<LoadBookReviews>(_onLoadBookReviews);
    on<LoadReviewEligibility>(_onLoadReviewEligibility);
    on<CreateReviewEvent>(_onCreateReview);
    on<UpdateReviewEvent>(_onUpdateReview);
    on<DeleteReviewEvent>(_onDeleteReview);
  }

  Future<void> _onLoadBookReviews(
    LoadBookReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final BookReviewsResponse response = await _getBookReviews(event.bookId);
      // Eligibility is best-effort — failure here must not break the list.
      ReviewEligibilityEntity? eligibility;
      try {
        eligibility = await _getReviewEligibility(event.bookId);
      } catch (_) {
        eligibility = null;
      }
      emit(
        ReviewsLoaded(
          reviews: response.reviews,
          averageRating: response.averageRating,
          totalReviews: response.totalReviews,
          eligibility: eligibility,
        ),
      );
    } catch (error) {
      emit(ReviewError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onLoadReviewEligibility(
    LoadReviewEligibility event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final eligibility = await _getReviewEligibility(event.bookId);
      emit(ReviewEligibilityLoaded(eligibility));
    } catch (error) {
      emit(ReviewError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onCreateReview(
    CreateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _createReview(
        bookId: event.bookId,
        rating: event.rating,
        title: event.title,
        comment: event.comment,
      );
      emit(const ReviewActionSuccess('Review submitted successfully'));
      // Reload reviews for the book
      add(LoadBookReviews(event.bookId));
    } catch (error) {
      emit(ReviewError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onUpdateReview(
    UpdateReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _updateReview(
        id: event.id,
        rating: event.rating,
        title: event.title,
        comment: event.comment,
      );
      emit(const ReviewActionSuccess('Review updated successfully'));
      // Reload reviews for the book
      add(LoadBookReviews(event.bookId));
    } catch (error) {
      emit(ReviewError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _deleteReview(event.id);
      emit(const ReviewActionSuccess('Review deleted successfully'));
      // Reload reviews for the book
      add(LoadBookReviews(event.bookId));
    } catch (error) {
      emit(ReviewError(ErrorHandler.getErrorMessage(error)));
    }
  }
}
