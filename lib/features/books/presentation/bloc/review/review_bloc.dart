import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_reviews.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetReviewsUseCase getReviews;

  ReviewBloc({required this.getReviews}) : super(ReviewInitial()) {
    on<FetchReviews>((event, emit) async {
      emit(ReviewLoading());
      try {
        final reviews = await getReviews(event.bookId);
        emit(ReviewLoaded(reviews));
      } catch (e) {
        emit(ReviewError('Failed to load reviews: ${e.toString()}'));
      }
    });
  }
}
