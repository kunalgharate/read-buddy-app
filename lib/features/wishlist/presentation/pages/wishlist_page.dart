import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/wishlist_book_entity.dart';
import '../bloc/wishlist_bloc.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WishlistBloc>()..add(LoadWishlist()),
      child: const _WishlistView(),
    );
  }
}

class _WishlistView extends StatelessWidget {
  const _WishlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: true,
      ),
      body: BlocConsumer<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistBookRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book removed from wishlist')),
            );
            context.read<WishlistBloc>().add(LoadWishlist());
          }
          if (state is WishlistBookAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book added to wishlist')),
            );
            context.read<WishlistBloc>().add(LoadWishlist());
          }
          if (state is WishlistError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const _WishlistShimmer();
          }
          if (state is WishlistLoaded) {
            if (state.books.isEmpty) {
              return _WishlistEmpty(
                onBrowse: () => Navigator.pop(context),
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<WishlistBloc>().add(LoadWishlist());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.books.length,
                itemBuilder: (context, index) => _WishlistBookCard(
                  book: state.books[index],
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

// ─── Empty State ───────────────────────────────────────────────────────────────

class _WishlistEmpty extends StatelessWidget {
  final VoidCallback onBrowse;
  const _WishlistEmpty({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start adding books you love and\nwe\'ll save them here for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Browse Books'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
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
}

// ─── Book Card ─────────────────────────────────────────────────────────────────

class _WishlistBookCard extends StatelessWidget {
  final WishlistBookEntity book;
  const _WishlistBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(book.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove from Wishlist'),
            content: Text('Remove "${book.title}" from your wishlist?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<WishlistBloc>().add(RemoveBookFromWishlist(book.id));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImageUrl.isNotEmpty
                    ? Image.network(
                        book.coverImageUrl,
                        width: 60,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _ConditionBadge(condition: book.condition),
                        const Spacer(),
                        if (book.price > 0)
                          Text(
                            '₹${book.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                onPressed: () {
                  context
                      .read<WishlistBloc>()
                      .add(RemoveBookFromWishlist(book.id));
                },
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remove from Wishlist',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 60,
      height: 85,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}

// ─── Condition Badge ───────────────────────────────────────────────────────────

class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    final color = _getConditionColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        condition,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getConditionColor() {
    switch (condition.toLowerCase()) {
      case 'new':
        return AppColors.primary;
      case 'like new':
        return AppColors.secondary;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ─── Shimmer Loading ───────────────────────────────────────────────────────────

class _WishlistShimmer extends StatefulWidget {
  const _WishlistShimmer();

  @override
  State<_WishlistShimmer> createState() => _WishlistShimmerState();
}

class _WishlistShimmerState extends State<_WishlistShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => _shimmerCard(),
        );
      },
    );
  }

  Widget _shimmerCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _shimmerBox(60, 85, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(double.infinity, 14),
                  const SizedBox(height: 8),
                  _shimmerBox(120, 12),
                  const SizedBox(height: 12),
                  _shimmerBox(60, 20, borderRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _shimmerBox(32, 32, borderRadius: 16),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {double borderRadius = 4}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFEEEEEE),
            Color(0xFFF5F5F5),
            Color(0xFFEEEEEE),
          ],
          stops: [
            (_animation.value - 1).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
