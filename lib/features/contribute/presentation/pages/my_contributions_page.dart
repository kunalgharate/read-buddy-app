import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/contribute/data/money_donation_service.dart';
import 'package:read_buddy_app/features/contribute/presentation/bloc/contribute_cubit.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/donate/presentation/widgets/donation_book_card.dart';

class MyContributionsPage extends StatelessWidget {
  const MyContributionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<DonateBookBloc>()..add(LoadDonationStats()),
        ),
        BlocProvider(
          create: (_) => ContributeCubit(MoneyDonationService(getIt<Dio>()))
            ..loadMoneyDonations(),
        ),
      ],
      child: const _MyContributionsContent(),
    );
  }
}

class _MyContributionsContent extends StatefulWidget {
  const _MyContributionsContent();

  @override
  State<_MyContributionsContent> createState() =>
      _MyContributionsContentState();
}

class _MyContributionsContentState extends State<_MyContributionsContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Contributions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Books'),
            Tab(text: 'Money'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BooksTab(),
          _MoneyTab(),
        ],
      ),
    );
  }
}

// ─── Books Tab ────────────────────────────────────────────────

class _BooksTab extends StatelessWidget {
  const _BooksTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonateBookBloc, DonateBookState>(
      builder: (context, state) {
        if (state is DonateBookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DonateBookError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context
                      .read<DonateBookBloc>()
                      .add(LoadDonationStats()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is DonationStatsLoaded) {
          final books = confirmedBooksSorted(state.stats.bookStatusList);

          if (books.isEmpty) {
            return _buildEmpty(
              'No confirmed donations yet.\n'
              'Books appear here after admin picks them up or marks them received.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return DonationBookCard(book: books[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Money Tab ────────────────────────────────────────────────

class _MoneyTab extends StatelessWidget {
  const _MoneyTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeCubit, ContributeState>(
      builder: (context, state) {
        if (state is ContributeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ContributeLoaded) {
          if (state.moneyDonations.isEmpty) {
            return _buildEmpty('No money donations yet.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.moneyDonations.length,
            itemBuilder: (context, index) {
              final donation = state.moneyDonations[index];
              final dt = DateTime.tryParse(donation.createdAt);
              final dateStr =
                  dt != null ? '${dt.day} ${_month(dt.month)} ${dt.year}' : '';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.attach_money,
                          color: Color(0xFFF59E0B), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u20B9${donation.amount}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(donation.status),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────

Widget _buildEmpty(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _statusBadge(String status) {
  Color color;
  switch (status.toLowerCase()) {
    case 'completed':
    case 'success':
      color = const Color(0xFF4CAF50);
      break;
    case 'donation_created':
    case 'pickup_requested':
    case 'pending':
      color = const Color(0xFF2196F3);
      break;
    default:
      color = AppColors.textSecondary;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.replaceAll('_', ' '),
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _month(int m) {
  const names = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return names[m];
}
