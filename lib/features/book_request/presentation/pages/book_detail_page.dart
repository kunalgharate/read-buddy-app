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
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';
import '../cubit/book_detail_variant_cubit.dart';
import '../../domain/entities/book_detail_entity.dart';
import 'book_request_form_page.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                getIt<BookRequestBloc>()..add(LoadBookDetail(bookId))),
        BlocProvider(
            create: (_) => BookDetailVariantCubit(
                  getIt<VariantRepository>(),
                  getIt<BookRequestRemoteDataSource>(),
                  getIt<Dio>(),
                  const FlutterSecureStorage(),
                )),
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
      backgroundColor: Colors.white,
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
      bottomNavigationBar:
          BlocBuilder<BookRequestBloc, BookRequestState>(
        builder: (context, state) {
          if (state is BookDetailLoaded) {
            return _BottomRequestBar(book: state.book);
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

    return SingleChildScrollView(
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
                      child:
                          CircularProgressIndicator(color: Color(0xFF2CE07F))),
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
        ],
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
              const Text('Available in',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF042153))),
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
                            horizontal: 16, vertical: 7),
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
      BuildContext context, BookVariantEntity? selectedVariant) {
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
      buttons.add(_actionBtn(
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
              },
            );
          }
        },
      ));
    }

    if (hasFormat('audiobook')) {
      final format = getFormat('audiobook');
      buttons.add(_actionBtn(
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
                  .map((p) => AudioBookTrack(
                        id: '${book.id}_${p.partNumber}',
                        title: p.title,
                        trackNumber: p.partNumber,
                        url: p.audioUrl!,
                        duration: Duration(seconds: p.duration),
                      ))
                  .toList(),
              totalDuration: Duration(seconds: format.totalDuration ?? 0),
            );
            Navigator.pushNamed(context, '/audiobook-player',
                arguments: audioBook);
          }
        },
      ));
    }

    if (hasFormat('videobook')) {
      final format = getFormat('videobook');
      buttons.add(_actionBtn(
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
              Navigator.pushNamed(context, '/videobook-player', arguments: {
                'bookTitle': book.title,
                'parts': videoParts,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('No video chapters available'),
                    behavior: SnackBarBehavior.floating),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No video content available'),
                  behavior: SnackBarBehavior.floating),
            );
          }
        },
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(
      children: buttons
          .expand((btn) => [Expanded(child: btn), const SizedBox(width: 10)])
          .toList()
        ..removeLast(),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
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

    return Stack(
      children: [
        // Cover image - full natural height
        SizedBox(
          width: double.infinity,
          child: book.coverImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => Container(
                    height: 300,
                    color: const Color(0xFF042153),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2CE07F),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 300,
                    color: const Color(0xFF042153),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 64,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 300,
                  color: const Color(0xFF042153),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: Colors.white30,
                    ),
                  ),
                ),
        ),
        // Gradient overlay at top for icon visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topPadding + 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: topPadding + 8,
          left: 8,
          child: _IconCircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        // Wishlist + Share icons
        Positioned(
          top: topPadding + 8,
          right: 8,
          child: Row(
            children: [
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
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
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
          const _StarRating(rating: 1),
          const SizedBox(height: 4),
          const Text(
            '10+ readers loved this',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
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
      child: Text(
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

// ─── Bottom Request Bar ─────────────────────────────────────────────────────

class _BottomRequestBar extends StatelessWidget {
  final BookDetailEntity book;

  const _BottomRequestBar({required this.book});

  @override
  Widget build(BuildContext context) {
    final variantState = context.watch<BookDetailVariantCubit>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final isPrime = profileState is ProfileLoaded && profileState.user.isPrime;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: variantState.hasActiveRequest
                  ? Colors.grey
                  : const Color(0xFF2CE07F),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: variantState.hasActiveRequest
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have already requested this book'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : () {
                    if (!isPrime) {
                      showPrimeRequiredDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookRequestFormPage(
                          bookId: book.id,
                          bookTitle: book.title,
                          coverImageUrl: book.coverImageUrl,
                        ),
                      ),
                    );
                  },
            child: Text(
              variantState.hasActiveRequest ? 'Already Requested' : 'Request Book',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
