import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/monthly_stats/domain/usecases/get_monthly_stats.dart';
import 'monthly_stats_event.dart';
import 'monthly_stats_state.dart';

/// BLoC for managing monthly statistics state
/// Handles events and emits states based on use case results
class MonthlyStatsBloc extends Bloc<MonthlyStatsEvent, MonthlyStatsState> {
  final GetMonthlyStats getMonthlyStats;

  MonthlyStatsBloc({
    required this.getMonthlyStats,
  }) : super(const MonthlyStatsInitial()) {
    // Register event handlers
    on<FetchMonthlyStats>(_onFetchMonthlyStats);
    on<RefreshMonthlyStats>(_onRefreshMonthlyStats);
  }

  /// Handle FetchMonthlyStats event
  Future<void> _onFetchMonthlyStats(
    FetchMonthlyStats event,
    Emitter<MonthlyStatsState> emit,
  ) async {
    // Emit loading state
    emit(const MonthlyStatsLoading());

    try {
      // Call use case to fetch data
      final stats = await getMonthlyStats();

      // Emit success state with data
      emit(MonthlyStatsLoaded(stats));
    } catch (e) {
      // Emit error state with message
      emit(MonthlyStatsError(e.toString()));
    }
  }

  /// Handle RefreshMonthlyStats event
  Future<void> _onRefreshMonthlyStats(
    RefreshMonthlyStats event,
    Emitter<MonthlyStatsState> emit,
  ) async {
    // If we have existing data, show it while refreshing
    if (state is MonthlyStatsLoaded) {
      final currentStats = (state as MonthlyStatsLoaded).stats;
      emit(MonthlyStatsRefreshing(currentStats));
    } else {
      emit(const MonthlyStatsLoading());
    }

    try {
      // Call use case to fetch fresh data
      final stats = await getMonthlyStats();

      // Emit success state with new data
      emit(MonthlyStatsLoaded(stats));
    } catch (e) {
      // Emit error state with message
      emit(MonthlyStatsError(e.toString()));
    }
  }
}
