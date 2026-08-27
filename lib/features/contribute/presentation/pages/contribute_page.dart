import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/contribute/data/money_donation_service.dart';
import 'package:read_buddy_app/features/contribute/presentation/bloc/contribute_cubit.dart';
import 'package:read_buddy_app/features/contribute/presentation/widgets/contribution_utils.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/format_screen.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({super.key});

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ContributeCubit(MoneyDonationService(getIt<Dio>()))
            ..loadMoneyDonations(),
        ),
        BlocProvider(
          create: (_) => getIt<DonateBookBloc>()..add(LoadDonationStats()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contribute'),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            bool isPrime = false;
            String userName = '';
            if (profileState is ProfileLoaded) {
              isPrime = profileState.user.isPrime;
              userName = profileState.user.name;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(userName, isPrime),
                  const SizedBox(height: 24),
                  if (!isPrime) ...[
                    _buildActionCards(context, isPrime),
                    const SizedBox(height: 28),
                  ] else ...[
                    _buildPrimeOnlyBookCard(context),
                    const SizedBox(height: 28),
                  ],
                  _buildImpactSection(context, isPrime),
                  const SizedBox(height: 28),
                  _buildRecentBookDonations(context),
                  const SizedBox(height: 28),
                  _buildRecentMoneyDonations(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, bool isPrime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Support ReadBuddy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isPrime)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Prime',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isPrime
              ? 'Donate books to our library network'
              : 'Choose how you want to contribute to our community',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, bool isPrime) {
    return Column(
      children: [
        _buildContributeBookCard(context),
        const SizedBox(height: 16),
        _buildBuyPrimeCard(context),
      ],
    );
  }

  Widget _buildPrimeOnlyBookCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Contribute a Book',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'As a Prime member, you can donate physical books to our library network.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Prime members can only contribute books. Monetary donations are not available after Prime activation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const BookFormatBottomSheet(),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Contribute a Book',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFormatChips(),
        ],
      ),
    );
  }

  Widget _buildContributeBookCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Contribute a Book',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Donate physical books to our library network. Once approved by admin, you get Prime for free!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const BookFormatBottomSheet(),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Contribute a Book',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFormatChips(),
        ],
      ),
    );
  }

  Widget _buildFormatChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('Hardcover', true),
        _chip('Digital Book', false),
        _chip('Audio Book', false),
        _chip('Video Book', false),
      ],
    );
  }

  Widget _chip(String label, bool available) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: available ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          if (!available) ...[
            const SizedBox(width: 4),
            Text(
              '(Soon)',
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ],
      ),
      backgroundColor: available
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.background,
      side: BorderSide(
        color: available
            ? AppColors.primary.withValues(alpha: 0.3)
            : AppColors.border,
      ),
    );
  }

  Widget _buildBuyPrimeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFFF59E0B),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Buy Prime Membership',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlock full access to borrow, read, listen & watch for just \u20B9100/year.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _benefitRow(Icons.menu_book, 'Borrow physical books'),
          _benefitRow(Icons.chrome_reader_mode, 'Read eBooks'),
          _benefitRow(Icons.headphones, 'Listen to Audiobooks'),
          _benefitRow(Icons.play_circle, 'Watch Videobooks'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, '/donate-money');
                if (result == true && context.mounted) {
                  context.read<ProfileBloc>().add(LoadProfileEvent());
                }
              },
              icon: const Icon(Icons.star, size: 20),
              label: const Text(
                'Buy Prime \u2014 \u20B9100',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSection(BuildContext context, bool isPrime) {
    return BlocBuilder<DonateBookBloc, DonateBookState>(
      builder: (context, bookState) {
        return BlocBuilder<ContributeCubit, ContributeState>(
          builder: (context, moneyState) {
            int booksDonated = 0;
            if (bookState is DonationStatsLoaded) {
              booksDonated = bookState.stats.booksDonated;
            }
            int moneyDonated = 0;
            if (moneyState is ContributeLoaded) {
              moneyDonated = moneyState.totalMoneyDonated;
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Personal Impact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _impactCard(
                          icon: Icons.menu_book,
                          label: 'Books Donated',
                          value: '$booksDonated',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!isPrime) ...[
                        Expanded(
                          child: _impactCard(
                            icon: Icons.attach_money,
                            label: 'Money Donated',
                            value: '\u20B9$moneyDonated',
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _impactCard(
                          icon: Icons.emoji_events,
                          label: 'Donor Badge',
                          value: isPrime ? 'Prime' : 'None',
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _impactCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookDonations(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donated Books',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DonateBookBloc, DonateBookState>(
            builder: (context, state) {
              if (state is DonateBookLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (state is DonationStatsLoaded) {
                if (state.stats.bookStatusList.isEmpty) {
                  return _buildEmptySection('No books donated yet.');
                }
                final items = state.stats.bookStatusList.take(5).toList();
                return Column(
                  children: items.map((d) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.menu_book,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${d.format} \u2022 ${d.categoryName ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          buildStatusBadge(d.status),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              if (state is DonateBookError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      state.message,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMoneyDonations(BuildContext context) {
    return BlocBuilder<ContributeCubit, ContributeState>(
      builder: (context, state) {
        if (state is ContributeLoading) {
          return const SizedBox.shrink();
        }
        if (state is ContributeError) {
          return const SizedBox.shrink();
        }
        if (state is ContributeLoaded) {
          if (state.moneyDonations.isEmpty) {
            return const SizedBox.shrink();
          }
          final items = state.moneyDonations.take(5).toList();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Money Donations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: items.map((d) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.attach_money,
                                color: Color(0xFFF59E0B), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\u20B9${d.amount}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(d.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          buildStatusBadge(d.status),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day} ${monthName(dt.month)} ${dt.year}';
  }

  Widget _buildEmptySection(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textHint),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
