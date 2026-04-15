import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import '../../../banner/presentation/bloc/banner_bloc.dart';
import '../../../homebooks/data/datasource/home_remote_datasource.dart';
import '../../../homebooks/data/model/home_monthly_status_model.dart';
import '../../../homebooks/domain/entities/book_entity.dart';
import '../../../homebooks/presentation/bloc/home_book_bloc.dart';
import '../../../homebooks/presentation/bloc/home_book_event.dart';
import '../../../homebooks/presentation/bloc/home_book_state.dart';

const _primary = Color(0xFF03405B);

// ─────────────────────────────────────────────
// MainTab — always provide both blocs
// ─────────────────────────────────────────────

class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeBloc>()..add(LoadHomeData())),
        BlocProvider(
            create: (_) =>
                getIt<BannerBloc>()), // no event yet — fired conditionally
      ],
      child: const _MainTabView(),
    );
  }
}

// ─────────────────────────────────────────────
// Main scrollable body
// ─────────────────────────────────────────────

class _MainTabView extends StatelessWidget {
  const _MainTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<HomeBloc>().add(LoadHomeData()),
                  child: const Text('Retry'),
                ),
              ]),
            );
          }

          if (state is HomeLoaded) {
            // Fire banner API only for prime users, only once
            if (state.isPrime) {
              context.read<BannerBloc>().add(GetBannerListEvent());
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BannerSection(
                      trendingCover:
                          state.trendingBooks.firstOrNull?.coverImageUrl,
                      isPrime: state.isPrime,
                    ),
                    const SizedBox(height: 32),
                    _BookSection(title: 'Latest', books: state.latestBooks),
                    const SizedBox(height: 32),
                    _BookSection(
                        title: 'Recommended for you',
                        books: state.trendingBooks),
                    const SizedBox(height: 32),
                    _MonthlyStatsCard(
                        dataSource: getIt<HomeRemoteDataSource>()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Banner — prime: API data | non-prime: static donation card
// ─────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  final String? trendingCover;
  final bool isPrime;
  const _BannerSection({this.trendingCover, required this.isPrime});

  @override
  Widget build(BuildContext context) {
    // Non-prime: skip BlocBuilder entirely, show static donation card
    if (!isPrime) {
      return _buildCard(
        title: 'Support a Reader',
        description: 'Donate a book and make a difference.',
      );
    }

    // Prime: wait for BannerBloc
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        if (state is! BannerLoaded || state.banners.isEmpty) {
          return _buildCard(
            title: 'Support a Reader',
            description: 'Donate a book and make a difference.',
          );
        }
        final banner = state.banners.first;
        return _buildCard(title: banner.title, description: banner.description);
      },
    );
  }

  Widget _buildCard({required String title, String? description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF03405B), Color(0xFF076A8F)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Left: text + donate button
            Positioned(
              left: 20,
              top: 20,
              bottom: 20,
              right: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      )),
                  if (description?.isNotEmpty == true)
                    Text(description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          height: 1.4,
                        )),
                  GestureDetector(
                    onTap: () {
                      // TODO: switch to donation tab
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3DAA6E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text('Donate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ],
              ),
            ),

            // Right: book cover raised above card
            Positioned(
              right: 16,
              top: -12,
              bottom: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: trendingCover?.isNotEmpty == true
                    ? Image.network(trendingCover!,
                        width: 115,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder())
                    : _coverPlaceholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 115,
        color: Colors.white12,
        child: const Icon(Icons.menu_book, color: Colors.white38, size: 40),
      );
}

// ─────────────────────────────────────────────
// Book section = header + horizontal list
// ─────────────────────────────────────────────

class _BookSection extends StatelessWidget {
  final String title;
  final List<BookEntity> books;

  const _BookSection({required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  )),
              GestureDetector(
                onTap: () {},
                child: const Row(children: [
                  Text('See All',
                      style: TextStyle(
                          fontSize: 13,
                          color: _primary,
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 11, color: _primary),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: books.isEmpty
              ? const Center(child: Text('No books available'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: books.length,
                  itemBuilder: (_, i) => _BookCard(book: books[i]),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Book Card
// ─────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final BookEntity book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: navigate to detail
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: book.coverImageUrl?.isNotEmpty == true
                      ? Image.network(book.coverImageUrl!,
                          height: 170,
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder())
                      : _imgPlaceholder(),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: _FormatBadge(format: book.format),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      )),
                  const SizedBox(height: 3),
                  Text(book.subtitle ?? book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF999999))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        height: 170,
        width: 140,
        decoration: const BoxDecoration(
          color: Color(0xFFE8EDF2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: const Icon(Icons.book, size: 44, color: Color(0xFFB0BEC5)),
      );
}

// ─────────────────────────────────────────────
// Format Badge
// ─────────────────────────────────────────────

class _FormatBadge extends StatelessWidget {
  final String? format;
  const _FormatBadge({this.format});

  static const _formats = {
    'ebook': ('E Book', Color(0xFF6B4EFF)),
    'audiobook': ('Audio', Color(0xFFFF6B35)),
  };

  @override
  Widget build(BuildContext context) {
    final entry = _formats[format?.toLowerCase()];
    final label = entry?.$1 ?? 'P Book';
    final color = entry?.$2 ?? const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          )),
    );
  }
}

// ─────────────────────────────────────────────
// Monthly Stats Card
// ─────────────────────────────────────────────

class _MonthlyStatsCard extends StatefulWidget {
  final HomeRemoteDataSource dataSource;
  const _MonthlyStatsCard({required this.dataSource});

  @override
  State<_MonthlyStatsCard> createState() => _MonthlyStatsCardState();
}

class _MonthlyStatsCardState extends State<_MonthlyStatsCard> {
  late final Future<MonthlyStatsModel> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.dataSource.getMonthlyStats();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: FutureBuilder<MonthlyStatsModel>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 100,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            if (snap.hasError) {
              return const SizedBox(
                  height: 100,
                  child: Center(child: Text('Could not load stats')));
            }

            final s = snap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Month',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _primary)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        icon: Icons.menu_book_outlined,
                        value: s.donatedBooks,
                        label: 'Book Donated'),
                    _StatItem(
                        icon: Icons.person_outline,
                        value: s.newUsers,
                        label: 'New Users'),
                    _StatItem(
                        icon: Icons.local_shipping_outlined,
                        value: s.deliveredBooks,
                        label: 'Deliveries'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: _primary),
        const SizedBox(height: 8),
        Text('$value',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: _primary)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
