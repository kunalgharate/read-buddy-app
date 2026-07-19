import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/banner/domain/entity/banner_entity.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/book_detail_page.dart';
import 'package:read_buddy_app/features/homebooks/data/datasource/home_remote_datasource.dart';
import 'package:read_buddy_app/features/homebooks/data/model/home_monthly_status_model.dart';
import 'package:read_buddy_app/features/homebooks/domain/entities/book_entity.dart';
import 'package:read_buddy_app/features/homebooks/presentation/bloc/home_book_bloc.dart';
import 'package:read_buddy_app/features/homebooks/presentation/bloc/home_book_event.dart';
import 'package:read_buddy_app/features/homebooks/presentation/bloc/home_book_state.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

const _primary = Color(0xFF03405B);

// ─────────────────────────────────────────────
// MainTab — always provide both blocs
// ─────────────────────────────────────────────

class MainTab extends StatefulWidget {
  final VoidCallback? onDonatePressed;
  const MainTab({super.key, this.onDonatePressed});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = getIt<HomeBloc>()..add(LoadHomeData());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider(create: (_) => getIt<BannerBloc>()),
      ],
      child: _MainTabView(onDonatePressed: widget.onDonatePressed),
    );
  }
}

class _MainTabView extends StatelessWidget {
  final VoidCallback? onDonatePressed;
  const _MainTabView({this.onDonatePressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: BlocConsumer<HomeBloc, HomeState>(
        listenWhen: (prev, curr) => curr is HomeLoaded && prev is! HomeLoaded,
        listener: (context, state) {
          if (state is HomeLoaded) {
            final profileState = context.read<ProfileBloc>().state;
            final isPrime = profileState is ProfileLoaded
                ? profileState.user.isPrime
                : false;
            if (isPrime) {
              context
                  .read<BannerBloc>()
                  .add(const GetBannerListEvent(typeFilter: 'homepage'));
            }
          }
        },
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
            // Use fresh isPrime from ProfileBloc — default to false if not loaded
            final profileState = context.watch<ProfileBloc>().state;
            final isPrime = profileState is ProfileLoaded
                ? profileState.user.isPrime
                : false;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BannerSection(
                      trendingCover:
                          state.trendingBooks.firstOrNull?.coverImageUrl,
                      isPrime: isPrime,
                      onDonatePressed: onDonatePressed,
                    ),
                    const SizedBox(height: 32),
                    _BookSection(
                      title: 'Latest',
                      books: state.latestBooks,
                    ),
                    const SizedBox(height: 32),
                    _BookSection(
                      title: 'Recommended for you',
                      books: state.recommendedBooks,
                    ),
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
// Banner — prime: image carousel | non-prime: static donation card
// ─────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  final String? trendingCover;
  final bool isPrime;
  final VoidCallback? onDonatePressed;
  const _BannerSection(
      {this.trendingCover, required this.isPrime, this.onDonatePressed});

  @override
  Widget build(BuildContext context) {
    if (!isPrime) {
      return _buildDonationCard();
    }

    // Prime: wait for banners, show loader until ready
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        if (state is BannerLoading || state is BannerInitial) {
          return const SizedBox(
            height: 175,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primary,
              ),
            ),
          );
        }
        if (state is BannerLoaded && state.banners.isNotEmpty) {
          return _BannerCarousel(banners: state.banners);
        }
        // Banners failed or empty — fall back to donation card
        return _buildDonationCard();
      },
    );
  }

  Widget _buildDonationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onDonatePressed,
        child: Container(
          height: 165,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF03405B), Color(0xFF076A8F)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 20,
                top: 20,
                bottom: 20,
                right: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Get Prime Membership',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        )),
                    const Text(
                        'Donate a book or buy membership to unlock all features.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3DAA6E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text('Get Prime',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ),
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
// Banner Carousel — auto-scrolling image banners
// ─────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  final List<BannerEntity> banners;
  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = widget.banners.length;
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_currentPage + 1) % _totalPages;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner.bannerImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF03405B),
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.white38, size: 40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (banner.description?.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  banner.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalPages, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 20 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2CE07F)
                    : const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Book section = header + horizontal list
// ─────────────────────────────────────────────

class _BookSection extends StatefulWidget {
  final String title;
  final List<BookEntity> books;

  const _BookSection({required this.title, required this.books});

  @override
  State<_BookSection> createState() => _BookSectionState();
}

class _BookSectionState extends State<_BookSection> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300 * widget.books.length.clamp(1, 10)),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              Text(widget.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  )),
              GestureDetector(
                onTap: _scrollToEnd,
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
          child: widget.books.isEmpty
              ? const Center(child: Text('No books available'))
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.books.length,
                  itemBuilder: (_, i) => _BookCard(book: widget.books[i]),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailPage(bookId: book.id),
        ),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
        color: color.withValues(alpha: 0.9),
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
                color: Colors.black.withValues(alpha: 0.07),
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
