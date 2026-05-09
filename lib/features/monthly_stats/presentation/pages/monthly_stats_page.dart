import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/monthly_stats/presentation/bloc/monthly_stats_bloc.dart';
import 'package:read_buddy_app/features/monthly_stats/presentation/bloc/monthly_stats_event.dart';
import 'package:read_buddy_app/features/monthly_stats/presentation/bloc/monthly_stats_state.dart';
import 'package:read_buddy_app/features/monthly_stats/presentation/widgets/monthly_stat_card.dart';

/// Page to display monthly statistics
/// Uses BLoC pattern for state management
class MonthlyStatsPage extends StatelessWidget {
  const MonthlyStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide BLoC instance from DI container
      create: (context) => getIt<MonthlyStatsBloc>()
        ..add(const FetchMonthlyStats()), // Fetch data on page load
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFDFD),
          elevation: 0,
          title: Text(
            'Monthly Statistics',
            style: GoogleFonts.poppins(
              color: const Color(0xFF052E44),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            // Refresh button
            BlocBuilder<MonthlyStatsBloc, MonthlyStatsState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF2CE07F),
                  ),
                  onPressed: state is MonthlyStatsLoading
                      ? null
                      : () {
                          context
                              .read<MonthlyStatsBloc>()
                              .add(const RefreshMonthlyStats());
                        },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MonthlyStatsBloc, MonthlyStatsState>(
          builder: (context, state) {
            // Handle different states
            if (state is MonthlyStatsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2CE07F),
                ),
              );
            } else if (state is MonthlyStatsLoaded) {
              return _buildStatsList(state.stats);
            } else if (state is MonthlyStatsRefreshing) {
              return Stack(
                children: [
                  _buildStatsList(state.currentStats),
                  const Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2CE07F),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Refreshing...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is MonthlyStatsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD64545),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF052E44),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<MonthlyStatsBloc>()
                              .add(const FetchMonthlyStats());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2CE07F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Initial state
            return const Center(
              child: Text('No data available'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsList(List stats) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No statistics available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2CE07F),
      onRefresh: () async {
        // This will be handled by BLoC
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return MonthlyStatCard(stat: stats[index]);
        },
      ),
    );
  }
}
