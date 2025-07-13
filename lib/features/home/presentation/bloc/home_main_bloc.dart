import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/home/domain/usecase/usecases.dart';
import 'home_main_event.dart';
import 'home_main_state.dart';

@injectable
class HomeMainBloc extends Bloc<HomeMainEvent, HomeMainState> {
  final GetLatestBooksUseCase getLatestBooksUseCase;
  final GetRecommendedBooksUseCase getRecommendedBooksUsecase;
  final GetStatsUseCase getStatsUseCase;
  HomeMainBloc({
    required this.getLatestBooksUseCase,
    required this.getRecommendedBooksUsecase,
    required this.getStatsUseCase,
  }) : super(HomeMainInitial()) {
    on<FetchMainHomeData>((event, emit) async {
      emit(HomeMainLoading());
      try {
        final latestBooks = await getLatestBooksUseCase(event.id);
        final recommendedBooks = await getRecommendedBooksUsecase(event.id);
        final stats = await getStatsUseCase();
        emit(HomeMainLoaded(
          latestBooks: latestBooks,
          recommendedBooks: recommendedBooks,
          stats: stats,
        ));
      } catch (e, stackTrace) {
        print('Error in HomeMainBloc: $e');
        print('Stack trace: $stackTrace');
        emit(HomeMainError("Fails to load"));
      }
    });
  }
}
