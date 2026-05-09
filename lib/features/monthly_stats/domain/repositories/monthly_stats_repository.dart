import 'package:read_buddy_app/features/monthly_stats/domain/entities/monthly_stat.dart';

/// Abstract repository interface (contract)
/// Defines what operations are available without implementation details
abstract class MonthlyStatsRepository {
  Future<List<MonthlyStat>> getMonthlyStats();
}
