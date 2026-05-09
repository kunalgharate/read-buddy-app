import 'package:read_buddy_app/features/monthly_stats/domain/entities/monthly_stat.dart';
import 'package:read_buddy_app/features/monthly_stats/domain/repositories/monthly_stats_repository.dart';

/// Use case for getting monthly statistics
/// Single responsibility: fetch monthly stats
/// Each use case has one call() method
class GetMonthlyStats {
  final MonthlyStatsRepository repository;

  GetMonthlyStats(this.repository);

  Future<List<MonthlyStat>> call() async {
    return await repository.getMonthlyStats();
  }
}
