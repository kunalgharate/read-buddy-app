import 'package:equatable/equatable.dart';

/// Base event class for MonthlyStatsBloc
abstract class MonthlyStatsEvent extends Equatable {
  const MonthlyStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch monthly statistics
class FetchMonthlyStats extends MonthlyStatsEvent {
  const FetchMonthlyStats();
}

/// Event to refresh monthly statistics
class RefreshMonthlyStats extends MonthlyStatsEvent {
  const RefreshMonthlyStats();
}
