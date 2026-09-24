import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/prime_required_dialog.dart';
import '../../../audiobook/domain/entities/audiobook.dart';
import '../../../bookcrud/domain/entities/book_variant_entity.dart';
import '../../../bookcrud/domain/respository/variant_repository.dart';
import '../../../borrow_order/domain/usecases/borrow_order_usecases.dart';
import '../../../library_inventory/presentation/widgets/library_picker_sheet.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../../reviews/presentation/bloc/review_bloc.dart';
import '../../../reviews/presentation/widgets/book_reviews_section.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';
import '../cubit/book_detail_variant_cubit.dart';
import '../../domain/entities/book_detail_entity.dart';
import '../widgets/report_concern_button.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<BookRequestBloc>()..add(LoadBookDetail(bookId)),
        ),
        BlocProvider(
          create: (_) => BookDetailVariantCubit(
            getIt<VariantRepository>(),
            getIt<BookRequestRemoteDataSource>(),
            getIt<Dio>(),
            const FlutterSecureStorage(),
          ),
        ),
      ],
      child: const _BookDetailView(),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  const _BookDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BookRequestBloc, BookRequestState>(
        listenWhen: (_, current) => current is BookRequestError,
        listener: (context, state) {
          if (state is BookRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookDetailLoaded) {
            return _BookDetailContent(book: state.book);
          }
          if (state is BookRequestLoading || state is BookRequestInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }
          if (state is BookRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BookDetailContent extends StatelessWidget {
  final BookDetailEntity book;

  const _BookDetailContent({required this.book});

  @override
  Widget build(BuildContext context) {
    // Trigger variant loading when this widget builds
    final cubit = context.read<BookDetailVariantCubit>();
    if (cubit.state.isLoading) {
      final profileState = context.read<ProfileBloc>().state;
      final wishlist =
          profileState is ProfileLoaded ? profileState.user.wishlist : [];
      cubit.loadVariants(
        bookId: book.id,
        inlineVariants: book.variants,
        userWishlist: wishlist,
      );
    }

    // Single shared ReviewBloc for the whole page so the title rating summary
    // and the reviews section stay in sync: a review mutation (create/edit/
    // delete) reloads reviews once and both widgets rebuild from the same
    // ReviewsLoaded state (single source of truth).
    return BlocProvider<ReviewBloc>(
      create: (_) => getIt<ReviewBloc>()..add(LoadBookReviews(book.id)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImageSection(book: book),
            _TitleSection(book: book),
            const SizedBox(height: 12),
            BlocBuilder<BookDetailVariantCubit, BookDetailVariantState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2CE07F),
                      ),
                    ),
                  );
                }
                return _LanguageAndActions(book: book);
              },
            ),
            const SizedBox(height: 12),
            _AboutSection(book: book),
            const SizedBox(height: 12),
            _HighlightSection(book: book),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Consume the shared ReviewBloc provided above instead of
              // creating a second independent instance.
              child: BookReviewsSection(bookId: book.id, useAncestorBloc: true),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Language Tabs + Action Buttons ────────────────────────────────────────

class _LanguageAndActions extends StatelessWidget {
  final BookDetailEntity book;
  const _LanguageAndActions({required this.book});

  bool _checkPrimeOrPrompt(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded && profileState.user.isPrime) {
      return true;
    }
    showPrimeRequiredDialog(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookDetailVariantCubit, BookDetailVariantState>(
      builder: (context, state) {
        final variants = state.variants;
        if (variants.isEmpty) return const SizedBox.shrink();
        final selectedLanguage = state.selectedLanguage;
        final selectedVariant = selectedLanguage != null
            ? variants.where((v) => v.language == selectedLanguage).firstOrNull
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF042153),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: variants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final lang = variants[index].language;
                    final isSelected = lang == selectedLanguage;
                    return GestureDetector(
                      onTap: () => context
                          .read<BookDetailVariantCubit>()
                          .selectLanguage(lang),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF042153)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF042153)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          lang[0].toUpperCase() + lang.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF042153),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(context, selectedVariant),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookVariantEntity? selectedVariant,
  ) {
    if (selectedVariant == null) return const SizedBox.shrink();
    final cubitState = context.read<BookDetailVariantCubit>().state;
    final buttons = <Widget>[];

    bool hasFormat(String type) =>
        selectedVariant.formats.any((f) => f.type == type);
    BookFormatEntity? getFormat(String type) {
      final m = selectedVariant.formats.where((f) => f.type == type);
      return m.isNotEmpty ? m.first : null;
    }

    if (hasFormat('ebook')) {
      final format = getFormat('ebook');
      buttons.add(
        _actionBtn(
          icon: Icons.chrome_reader_mode_rounded,
          label: 'Read',
          color: const Color(0xFF0D9488),
          onTap: () {
            if (!_checkPrimeOrPrompt(context)) return;
            if (format?.fileUrl != null) {
              final url = format!.fileUrl!;
              Navigator.pushNamed(
                context,
                url.toLowerCase().contains('.epub')
                    ? '/epub-reader'
                    : '/pdf-reader',
                arguments: {
                  'url': url,
                  'title': book.title,
                  'language': cubitState.selectedLanguage ?? 'en',
                  'bookId': book.id,
                  'coverImageUrl': book.coverImageUrl,
                  'author': book.author,
                },
              );
            }
          },
        ),
      );
    }

    if (hasFormat('audiobook')) {
      final format = getFormat('audiobook');
      buttons.add(
        _actionBtn(
          icon: Icons.headphones_rounded,
          label: 'Listen',
          color: const Color(0xFFD97706),
          onTap: () {
            if (!_checkPrimeOrPrompt(context)) return;
            if (format != null && format.parts.isNotEmpty) {
              final audioBook = AudioBook(
                id: book.id,
                title: book.title,
                author: book.author,
                coverUrl: book.coverImageUrl,
                tracks: format.parts
                    .where((p) => p.audioUrl != null && p.audioUrl!.isNotEmpty)
                    .map(
                      (p) => AudioBookTrack(
                        id: '${book.id}_${p.partNumber}',
                        title: p.title,
                        trackNumber: p.partNumber,
                        url: p.audioUrl!,
                        duration: Duration(seconds: p.duration),
                      ),
                    )
                    .toList(),
                totalDuration: Duration(seconds: format.totalDuration ?? 0),
              );
              Navigator.pushNamed(
                context,
                '/audiobook-player',
                arguments: audioBook,
              );
            }
          },
        ),
      );
    }

    if (hasFormat('videobook')) {
      final format = getFormat('videobook');
      buttons.add(
        _actionBtn(
          icon: Icons.play_circle_rounded,
          label: 'Watch',
          color: const Color(0xFF7C3AED),
          onTap: () {
            if (!_checkPrimeOrPrompt(context)) return;
            if (format != null && format.parts.isNotEmpty) {
              final videoParts = format.parts
                  .where((p) => p.videoUrl != null && p.videoUrl!.isNotEmpty)
                  .toList();
              if (videoParts.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  '/videobook-player',
                  arguments: {
                    'bookTitle': book.title,
                    'parts': videoParts,
                    'bookId': book.id,
                    'coverImageUrl': book.coverImageUrl,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No video chapters available'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No video content available'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      );
    }

    // Physical (borrowable) formats and their availability — mirrors web's
    // hasAvailablePhysicalCopy gating.
    final physicalFormats = selectedVariant.formats
        .where((f) => f.type == 'hardcover' || f.type == 'paperback')
        .toList();
    final hasAvailablePhysicalCopy = physicalFormats.any(
      (f) => (f.availableCopies ?? 0) > 0,
    );

    // Borrow button is grouped WITH the read/listen/watch actions (like web),
    // and only shown when the book has physical copies. When it has physical
    // formats but none are available, it is shown disabled as 'Unavailable'.
    final actionButtons = <Widget>[
      if (physicalFormats.isNotEmpty)
        _BorrowActionButton(
          book: book,
          available: hasAvailablePhysicalCopy,
        ),
      ...buttons,
    ];

    if (actionButtons.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actionButtons,
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cover Image with overlaid back / wishlist / share icons ───────────────

class _CoverImageSection extends StatelessWidget {
  final BookDetailEntity book;

  const _CoverImageSection({required this.book});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Bounded, centered cover to match the web layout (h-45 w-32 ≈ 180x128),
    // instead of a full-width, full-height image.
    const coverWidth = 128.0;
    const coverHeight = 180.0;

    Widget cover() {
      if (book.coverImageUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: book.coverImageUrl,
          width: coverWidth,
          height: coverHeight,
          fit: BoxFit.contain,
          placeholder: (_, __) => Container(
            color: const Color(0xFFF0F0F0),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFF0F0F0),
            child: const Center(
              child:
                  Icon(Icons.menu_book_rounded, size: 48, color: Colors.grey),
            ),
          ),
        );
      }
      return Container(
        color: const Color(0xFFF0F0F0),
        child: const Center(
          child: Icon(Icons.menu_book_rounded, size: 48, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Top bar: back button (left) + wishlist/share (right).
        Padding(
          padding: EdgeInsets.fromLTRB(8, topPadding + 8, 8, 0),
          child: Row(
            children: [
              _IconCircleButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              BlocBuilder<BookDetailVariantCubit, BookDetailVariantState>(
                builder: (context, state) {
                  return _IconCircleButton(
                    icon: state.isInWishlist
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    onTap: () => context
                        .read<BookDetailVariantCubit>()
                        .toggleWishlist(book.id),
                  );
                },
              ),
              const SizedBox(width: 8),
              _IconCircleButton(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Centered, bounded cover. Shadow lives on the outer (unclipped)
        // container; the image itself is clipped to the rounded corners.
        Center(
          child: Container(
            width: coverWidth,
            height: coverHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: cover(),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─── Title / Donated by / Rating ───────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  final BookDetailEntity book;

  const _TitleSection({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Donated by - ${book.owner.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Live rating driven by the real reviews API (averageRating /
          // totalReviews). Consumes the shared ReviewBloc provided by
          // _BookDetailContent so it stays in sync with the reviews section.
          _BookRatingSummary(bookId: book.id),
        ],
      ),
    );
  }
}

/// Shows the real average rating and review count for the book by listening
/// to [ReviewBloc]. Replaces the previously hardcoded 1-star rating and the
/// fake "10+ readers loved this" copy.
class _BookRatingSummary extends StatelessWidget {
  final String bookId;

  const _BookRatingSummary({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is ReviewsLoaded && state.totalReviews > 0) {
          final label = state.totalReviews == 1
              ? '1 reader rated this'
              : '${state.totalReviews} readers rated this';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StarRating(rating: state.averageRating),
              const SizedBox(height: 4),
              Text(
                '${state.averageRating.toStringAsFixed(1)} · $label',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          );
        }

        // Distinct failure state: a request error must NOT be conflated with
        // "no ratings yet". Offer a lightweight retry.
        if (state is ReviewError) {
          return Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 18,
                color: Color(0xFF999999),
              ),
              const SizedBox(width: 6),
              const Text(
                'Ratings unavailable',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () =>
                    context.read<ReviewBloc>().add(LoadBookReviews(bookId)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2CE07F),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // "No ratings yet" is reserved ONLY for a successfully-loaded response
        // with zero reviews. While loading (ReviewLoading/ReviewInitial) show
        // the same neutral placeholder without any misleading rating value.
        if (state is ReviewsLoaded) {
          // Successfully loaded, but totalReviews == 0.
          return const _NoRatingsYet();
        }

        // Loading / initial — neutral placeholder, no hardcoded rating.
        return const _NoRatingsYet();
      },
    );
  }
}

/// Neutral placeholder shown for a successfully-loaded zero-review book (and
/// while the reviews are still loading). Deliberately distinct from the
/// [ReviewError] "Ratings unavailable" state.
class _NoRatingsYet extends StatelessWidget {
  const _NoRatingsYet();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StarRating(rating: 0),
        SizedBox(height: 4),
        Text(
          'No ratings yet',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
          size: 20,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }
}

// ─── About This Book ───────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final BookDetailEntity book;

  const _AboutSection({required this.book});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'About This Book',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.description.isNotEmpty
                ? book.description
                : 'No description available.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              height: 1.6,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: ReportConcernButton(bookId: book.id),
          ),
        ],
      ),
    );
  }
}

// ─── Highlight ─────────────────────────────────────────────────────────────

class _HighlightSection extends StatelessWidget {
  final BookDetailEntity book;

  const _HighlightSection({required this.book});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _HighlightRow(label: 'Book Type', value: _capitalize(book.format)),
      _HighlightRow(label: 'Author', value: book.author),
      _HighlightRow(
        label: 'Genre',
        value: book.tags.isNotEmpty ? book.tags.join(', ') : '—',
      ),
      _HighlightRow(label: 'Language', value: _capitalize(book.language)),
      _HighlightRow(
        label: 'Copies Available',
        value: book.numberOfCopies.toString(),
      ),
      _HighlightRow(label: 'Book Format', value: _capitalize(book.format)),
      _HighlightRow(
        label: 'Condition',
        value: _capitalize(book.condition),
      ),
      _HighlightRow(
        label: 'Location',
        value:
            '${_capitalize(book.address.city)}, ${book.address.state.toUpperCase()}',
      ),
    ];

    return _SectionCard(
      title: 'Highlight',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _HighlightRow extends StatelessWidget {
  final String label;
  final String value;

  const _HighlightRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label - $value',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF333333),
          height: 1.5,
        ),
      ),
    );
  }
}

// ─── Shared section card ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── Borrow action button (grouped with Read/Listen/Watch) ──────────────────

class _BorrowActionButton extends StatefulWidget {
  final BookDetailEntity book;
  final bool available;

  const _BorrowActionButton({required this.book, required this.available});

  @override
  State<_BorrowActionButton> createState() => _BorrowActionButtonState();
}

class _BorrowActionButtonState extends State<_BorrowActionButton> {
  bool _isAdding = false;

  BookDetailEntity get book => widget.book;

  /// Physical formats that can be borrowed via the cart.
  static const _physicalFormats = ['hardcover', 'paperback'];

  BookVariantEntity? _selectedVariant(BookDetailVariantState state) {
    final variants = state.variants;
    if (variants.isEmpty) return null;
    final lang = state.selectedLanguage;
    if (lang == null) return variants.first;
    final match = variants.where((v) => v.language == lang);
    return match.isNotEmpty ? match.first : variants.first;
  }

  BookFormatEntity? _borrowableFormat(BookVariantEntity variant) {
    // Prefer an IN-STOCK physical format (matching the availability check),
    // so we never send an out-of-stock format's id to the cart. Fall back to
    // any physical format, then any format at all.
    for (final type in _physicalFormats) {
      final inStock = variant.formats.where(
        (f) => f.type == type && (f.availableCopies ?? 0) > 0,
      );
      if (inStock.isNotEmpty) return inStock.first;
    }
    for (final type in _physicalFormats) {
      final match = variant.formats.where((f) => f.type == type);
      if (match.isNotEmpty) return match.first;
    }
    return variant.formats.isNotEmpty ? variant.formats.first : null;
  }

  Future<void> _addToCartAndOpen(BookDetailVariantState variantState) async {
    final variant = _selectedVariant(variantState);
    if (variant == null) {
      _showSnack('This book has no available editions to borrow');
      return;
    }
    final format = _borrowableFormat(variant);
    if (format == null || format.id == null) {
      _showSnack('Selected edition has no borrowable format');
      return;
    }

    // Let the user pick WHICH library to borrow from (nearest first) and HOW
    // they want it (Pickup within range / Delivery anywhere in city). The
    // picker resolves the correct variantId/formatId for the chosen library's
    // inventory, so we prefer those over the locally auto-selected ones.
    final pick = await LibraryPickerSheet.show(
      context,
      bookId: book.id,
      bookTitle: book.title,
      preferredVariantId: variant.id,
    );
    // User dismissed the picker without choosing — abort silently.
    if (pick == null) return;
    if (!mounted) return;

    setState(() => _isAdding = true);
    // Capture navigator + messenger up front: switching to a digital-only
    // variant mid-add can dispose this widget, so we must not rely on `context`
    // /`mounted` afterwards to show success and open the cart.
    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<AddBookToOrder>()(
        bookId: book.id,
        variantId: pick.variantId,
        formatId: pick.formatId,
        libraryId: pick.libraryId,
        fulfillmentMethod: pick.fulfillmentMethod,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Added to your borrow cart — '
            '${pick.fulfillmentMethod == 'PICKUP' ? 'Pickup' : 'Delivery'} '
            'from ${pick.libraryName}',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      navigator.pushNamed('/order-cart');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variantState = context.watch<BookDetailVariantCubit>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final isPrime = profileState is ProfileLoaded && profileState.user.isPrime;
    final hasActiveRequest = variantState.hasActiveRequest;

    // When there are physical formats but none available, show a disabled
    // 'Unavailable' button (mirrors web). Otherwise a normal Add to Cart.
    final unavailable = !widget.available;

    final Color bg;
    final IconData icon;
    final String label;
    if (hasActiveRequest) {
      bg = Colors.grey;
      icon = Icons.timelapse_rounded;
      label = 'Requested';
    } else if (unavailable) {
      bg = const Color(0xFFEF4444);
      icon = Icons.shopping_bag_outlined;
      label = 'Unavailable';
    } else {
      bg = const Color(0xFF2CE07F);
      icon = Icons.shopping_bag_outlined;
      label = 'Borrow';
    }

    final enabled = !_isAdding && !hasActiveRequest && !unavailable;

    VoidCallback? onPressed;
    if (enabled) {
      onPressed = () {
        if (!isPrime) {
          showPrimeRequiredDialog(context);
          return;
        }
        _addToCartAndOpen(variantState);
      };
    } else if (hasActiveRequest) {
      // Informational tap; still a real (enabled) button so it stays
      // keyboard-focusable and announces its label.
      onPressed = () => _showSnack('You have already requested this book');
    } else {
      // Unavailable / in-flight → semantically disabled (null onPressed).
      onPressed = null;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: bg.withValues(alpha: 0.6),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAdding)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            _isAdding ? 'Adding…' : label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
