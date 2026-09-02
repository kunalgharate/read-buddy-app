import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/donate/presentation/widgets/donation_book_card.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'format_screen.dart';

class DonationTab extends StatefulWidget {
  const DonationTab({super.key});

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _cardShadow = Color(0x0D000000);

  @override
  State<DonationTab> createState() => _DonationTabState();
}

class _DonationTabState extends State<DonationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DonateBookBloc>().add(LoadDonationStats());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _DonationTabContent();
  }
}

// ─── Main Content ─────────────────────────────────────────────

class _DonationTabContent extends StatelessWidget {
  const _DonationTabContent();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;
    final scaffoldBg = AppColors.scaffoldBackground(context);
    final textPrimary = AppColors.textPrimaryColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Contribute',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/my-contributions'),
            child: Text(
              'My Contributions',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w500,
                color: DonationTab._primaryGreen,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DonateBookBloc>().add(LoadDonationStats());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Your Impact ---
              Text(
                'Your Impact',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: size.height * 0.015),
              const _ImpactSection(),
              SizedBox(height: size.height * 0.035),

              // --- Recent Donations ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Donations',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my-contributions');
                    },
                    child: Text(
                      'See all',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w500,
                        color: DonationTab._primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              const _BookStatusSection(),
              SizedBox(height: size.height * 0.04),

              // --- Donation Section Label ---
              Text(
                'Contribution',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: size.height * 0.015),

              // --- Donate Book Button ---
              _DonationButton(
                icon: Icons.add,
                label: 'Donate a Book',
                color: const Color(0xFF10B981),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surfaceColor(context),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const BookFormatBottomSheet(),
                ),
              ),
              SizedBox(height: size.height * 0.03),

              // --- Buy Prime Button (hidden when already prime) ---
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  if (profileState is ProfileLoaded &&
                      profileState.user.isPrime) {
                    return const SizedBox.shrink();
                  }
                  return _DonationButton(
                    icon: Icons.star,
                    label: 'Buy Prime \u2014 \u20B9100',
                    color: const Color(0xFFF59E0B),
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/donate-money');
                      if (result == true && context.mounted) {
                        context
                            .read<DonateBookBloc>()
                            .add(LoadDonationStats());
                      }
                    },
                  );
                },
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Impact Section ───────────────────────────────────────────

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<DonateBookBloc, DonateBookState>(
      builder: (context, state) {
        if (state is DonateBookLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: DonationTab._primaryGreen,
              ),
            ),
          );
        }

        if (state is DonateBookError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load stats',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    color: const Color(0xFFD64545),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<DonateBookBloc>().add(LoadDonationStats()),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      color: DonationTab._primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final booksDonated =
            state is DonationStatsLoaded ? state.stats.booksDonated : 0;
        final studentsHelped =
            state is DonationStatsLoaded ? state.stats.studentsHelped : 0;

        return Row(
          children: [
            Expanded(
              child: _ImpactCard(
                icon: Icons.book,
                iconColor: const Color(0xFF2CE07F),
                iconBgColor: const Color(0x1A2CE07F),
                count: booksDonated.toString().padLeft(2, '0'),
                label: 'Books Donated',
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: _ImpactCard(
                icon: Icons.people,
                iconColor: const Color(0xFF2196F3),
                iconBgColor: const Color(0x1A2196F3),
                count: studentsHelped > 20 ? '20+' : studentsHelped.toString(),
                label: 'Students Helped',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Book Status Section ──────────────────────────────────────

class _BookStatusSection extends StatelessWidget {
  const _BookStatusSection();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Shared card decoration used in all states
    BoxDecoration cardDecoration() => BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
              color: DonationTab._cardShadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        );

    return BlocBuilder<DonateBookBloc, DonateBookState>(
      builder: (context, state) {
        // --- Loading ---
        if (state is DonateBookLoading) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: cardDecoration(),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: DonationTab._primaryGreen,
                ),
              ),
            ),
          );
        }

        // --- Error ---
        if (state is DonateBookError) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: cardDecoration(),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load books',
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.035,
                      color: const Color(0xFFD64545),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<DonateBookBloc>().add(LoadDonationStats()),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        color: DonationTab._primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // --- Loaded ---
        if (state is DonationStatsLoaded) {
          final books = confirmedBooksSorted(state.stats.bookStatusList);

          // --- Empty state ---
          if (books.isEmpty) {
            return Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: cardDecoration(),
              child: Center(
                child: Text(
                  'No confirmed donations yet',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
              ),
            );
          }

          // Show max 5
          final display = books.length > 5 ? books.sublist(0, 5) : books;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            decoration: cardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: display.map((book) {
                return DonationBookCard(
                  book: book,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/donated-book-detail',
                      arguments: DonatedBooksEntity(
                        id: book.id,
                        bookTitle: book.title,
                        format: book.format,
                        status: book.status,
                        category: book.categoryName ?? '',
                        donorName: 'You',
                        coverImageUrl: book.coverImageUrl ?? '',
                        createdAt: book.createdAt ??
                            DateTime.now().toIso8601String(),
                        language: 'English',
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Donation Button ──────────────────────────────────────────

class _DonationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DonationButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.065,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: size.width * 0.055),
            SizedBox(width: size.width * 0.02),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Impact Card ──────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String count;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DonationTab._cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: size.width * 0.06),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor(context),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.03,
              color: AppColors.textSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

