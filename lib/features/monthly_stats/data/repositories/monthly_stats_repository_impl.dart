import 'package:read_buddy_app/features/monthly_stats/domain/entities/monthly_stat.dart';
import 'package:read_buddy_app/features/monthly_stats/domain/repositories/monthly_stats_repository.dart';
import 'package:read_buddy_app/features/monthly_stats/data/datasources/monthly_stats_remote_datasource.dart';

/// Repository implementation
/// Bridges data sources and domain layer
class MonthlyStatsRepositoryImpl implements MonthlyStatsRepository {
  final MonthlyStatsRemoteDataSource remoteDataSource;

  MonthlyStatsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MonthlyStat>> getMonthlyStats() async {
    // Repository can add caching, error handling, or data transformation here
    return await remoteDataSource.getMonthlyStats();
  }
}
