import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';
import 'format_screen.dart';

class DonationTab extends StatefulWidget {
  const DonationTab({super.key});

  static const _primaryGreen = Color(0xFF2CE07F);
  static const _textDark = Color(0xFF052E44);
  static const _background = Color(0xFFFDFDFD);
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

    return Scaffold(
      backgroundColor: DonationTab._background,
      appBar: AppBar(
        backgroundColor: DonationTab._background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Get Prime',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.w600,
            color: DonationTab._textDark,
          ),
        ),
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
                  color: DonationTab._textDark,
                ),
              ),
              SizedBox(height: size.height * 0.015),
              const _ImpactSection(),
              SizedBox(height: size.height * 0.035),

              // --- Recent Donations (heading changed) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Donations', // ✅ Changed from 'Your Book Status'
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: DonationTab._textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/donated-books');
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
                'Donation',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w600,
                  color: DonationTab._textDark,
                ),
              ),
              SizedBox(height: size.height * 0.015),

              // --- Donate Book Button ---
              _DonationButton(
                icon: Icons.add,
                label: 'Donate a Book',
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const BookFormatBottomSheet(),
                ),
              ),
              SizedBox(height: size.height * 0.03),
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

  // Maps raw API status string → (display label, color)
  ({String label, Color color}) _resolveStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'donation_created':
      case 'pickup_requested':
      case 'pending':
        return (label: 'Pending', color: const Color(0xFFFFC107));
      case 'accepted':
      case 'processing':
      case 'out_for_pickup':
        return (label: 'In Progress', color: const Color(0xFF2196F3));
      case 'completed':
      case 'delivered':
      case 'success':
        return (label: 'Completed', color: const Color(0xFF4CAF50));
      case 'cancelled':
      case 'rejected':
        return (label: 'Cancelled', color: const Color(0xFFF44336));
      default:
        return (
          label: apiStatus.replaceAll('_', ' ').toUpperCase(),
          color: const Color(0xFF9E9E9E),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Shared card decoration used in all states
    BoxDecoration cardDecoration() => const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
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
          final books = state.stats.bookStatusList;

          // --- Empty state ---
          if (books.isEmpty) {
            return Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: cardDecoration(),
              child: Center(
                child: Text(
                  'No donated books yet',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.035,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
            );
          }

          // Show max 5 books
          final itemCount = books.length > 5 ? 5 : books.length;

          final listItems = <Widget>[];

          for (var i = 0; i < itemCount; i++) {
            // Add a thin divider between rows (not before the first)
            if (i != 0) {
              listItems.add(const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF0F0F0),
              ));
            }

            // Resolve status label + color
            final resolved = _resolveStatus(books[i].status);

            listItems.add(
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/donated-book-detail',
                    arguments: DonatedBooksEntity(
                      id: books[i].id,
                      bookTitle: books[i].title,
                      format: books[i].format,
                      status: books[i].status,
                      category: books[i].categoryName ?? '',
                      donorName: 'You',
                      coverImageUrl: books[i].coverImageUrl ?? '',
                      createdAt: books[i].createdAt ??
                          DateTime.now().toIso8601String(),
                      language: 'English',
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  child: _BookStatusRow(
                    title: books[i].title,
                    format: books[i].format,
                    status: resolved.label,
                    statusColor: resolved.color,
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            decoration: cardDecoration(),
            child: Column(
              children: listItems,
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
  final VoidCallback onPressed;

  const _DonationButton({
    required this.icon,
    required this.label,
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
          backgroundColor: const Color(0xFF2CE07F),
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
        color: Colors.white,
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
              color: DonationTab._textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.03,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Book Status Row ──────────────────────────────────────────

class _BookStatusRow extends StatelessWidget {
  final String title;
  final String format;
  final String status;
  final Color statusColor;

  const _BookStatusRow({
    required this.title,
    required this.format,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: DonationTab._textDark,
                ),
              ),
              Text(
                format,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.035,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.007,
          ),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: size.width * 0.03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
