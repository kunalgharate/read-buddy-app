import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/monthly_stats/domain/entities/monthly_stat.dart';

/// Base state class for MonthlyStatsBloc
abstract class MonthlyStatsState extends Equatable {
  const MonthlyStatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class MonthlyStatsInitial extends MonthlyStatsState {
  const MonthlyStatsInitial();
}

/// State when data is being loaded
class MonthlyStatsLoading extends MonthlyStatsState {
  const MonthlyStatsLoading();
}

/// State when data is successfully loaded
class MonthlyStatsLoaded extends MonthlyStatsState {
  final List<MonthlyStat> stats;

  const MonthlyStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// State when an error occurs
class MonthlyStatsError extends MonthlyStatsState {
  final String message;

  const MonthlyStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when refreshing data (shows existing data while loading new)
class MonthlyStatsRefreshing extends MonthlyStatsState {
  final List<MonthlyStat> currentStats;

  const MonthlyStatsRefreshing(this.currentStats);

  @override
  List<Object?> get props => [currentStats];
}
