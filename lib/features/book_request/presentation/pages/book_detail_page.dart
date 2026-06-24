import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/prime_required_dialog.dart';
import '../../../bookcrud/data/model/book_crud_model.dart';
import '../../../bookcrud/domain/entities/book_variant_entity.dart';
import '../../../bookcrud/domain/respository/variant_repository.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';
import '../../domain/entities/book_detail_entity.dart';
import 'book_request_form_page.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookRequestBloc>()..add(LoadBookDetail(bookId)),
      child: const _BookDetailView(),
    );
  }
}

class _BookDetailView extends StatefulWidget {
  const _BookDetailView();

  @override
  State<_BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<_BookDetailView> {
  BookDetailEntity? _cachedBook;
  List<BookVariantEntity> _variants = [];

  void _updateVariants(List<BookVariantEntity> variants) {
    setState(() => _variants = variants);
  }

  bool get _hasPhysicalCopy {
    for (final variant in _variants) {
      for (final format in variant.formats) {
        if (format.type == 'hardcover' || format.type == 'paperback') {
          return true;
        }
      }
    }
    return false;
  }

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
            _cachedBook = state.book;
            return _BookDetailContent(
                book: state.book, onVariantsLoaded: _updateVariants);
          }
          if (state is BookRequestCreating && _cachedBook != null) {
            return _BookDetailContent(
                book: _cachedBook!, onVariantsLoaded: _updateVariants);
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
      bottomNavigationBar: BlocBuilder<BookRequestBloc, BookRequestState>(
        builder: (context, state) {
          if (state is BookDetailLoaded) {
            return _BottomActionBar(
                book: state.book, hasPhysicalCopy: _hasPhysicalCopy);
          }
          if (state is BookRequestCreating && _cachedBook != null) {
            return _BottomActionBar(
                book: _cachedBook!, hasPhysicalCopy: _hasPhysicalCopy);
          }
          if (state is BookRequestError && _cachedBook != null) {
            return _BottomActionBar(
                book: _cachedBook!, hasPhysicalCopy: _hasPhysicalCopy);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final BookDetailEntity book;
  final bool hasPhysicalCopy;

  const _BottomActionBar({required this.book, this.hasPhysicalCopy = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E2939),
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add to Wishlist',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: hasPhysicalCopy
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookRequestFormPage(
                            bookId: book.id,
                            bookTitle: book.title,
                            coverImageUrl: book.coverImageUrl,
                          ),
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CE07F),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Request to Book',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasPhysicalCopy ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookDetailContent extends StatefulWidget {
  final BookDetailEntity book;
  final void Function(List<BookVariantEntity>)? onVariantsLoaded;

  const _BookDetailContent({required this.book, this.onVariantsLoaded});

  @override
  State<_BookDetailContent> createState() => _BookDetailContentState();
}

class _BookDetailContentState extends State<_BookDetailContent> {
  List<BookVariantEntity> _variants = [];
  bool _isLoadingVariants = true;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    // First try using inline variants from book response
    if (widget.book.variants.isNotEmpty) {
      setState(() {
        _variants = widget.book.variants;
        _isLoadingVariants = false;
        _selectedLanguage = _variants.first.language;
      });
      widget.onVariantsLoaded?.call(_variants);
      return;
    }

    // Fallback: fetch separately if not inline
    try {
      final repository = getIt<VariantRepository>();
      final variants = await repository.getVariantsForBook(widget.book.id);
      if (mounted) {
        setState(() {
          _variants = variants;
          _isLoadingVariants = false;
          if (variants.isNotEmpty) {
            _selectedLanguage = variants.first.language;
          }
        });
        widget.onVariantsLoaded?.call(variants);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVariants = false);
      }
    }
  }

  BookVariantEntity? get _selectedVariant {
    if (_selectedLanguage == null || _variants.isEmpty) return null;
    final matches = _variants.where((v) => v.language == _selectedLanguage);
    return matches.isNotEmpty ? matches.first : null;
  }

  bool _hasFormat(String type) {
    return _selectedVariant?.formats.any((f) => f.type == type) ?? false;
  }

  BookFormatEntity? _getFormat(String type) {
    final matches = _selectedVariant?.formats.where((f) => f.type == type);
    return (matches != null && matches.isNotEmpty) ? matches.first : null;
  }

  /// Checks if user is Prime. If not, shows donation dialog. Returns true if Prime.
  bool _checkPrimeOrPrompt(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded && profileState.user.isPrime) {
      return true;
    }
    showPrimeRequiredDialog(context);
    return false;
  }

  BookCrudModel _toBookCrudModel(BookDetailEntity detail) {
    return BookCrudModel(
      id: detail.id,
      title: detail.title,
      author: detail.author,
      publisher: detail.publisher,
      publicationYear: detail.publicationYear,
      isbn: detail.isbn,
      edition: '',
      condition: detail.condition,
      isAvailable: detail.isAvailable,
      status: detail.status,
      numberOfCopies: detail.numberOfCopies,
      format: detail.format,
      language: detail.language,
      genre: '',
      tags: detail.tags,
      category: '',
      ownerId: detail.owner.id,
      location: detail.address.city,
      coverImageUrl: detail.coverImageUrl,
      additionalImages: [],
      description: detail.description,
      notes: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverImageSection(book: widget.book),
          _TitleSection(book: widget.book),
          const SizedBox(height: 12),
          // ── Language Tabs + Action Buttons ────────────────────────────
          if (!_isLoadingVariants && _variants.isNotEmpty)
            _buildLanguageAndActions(),
          if (_isLoadingVariants)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2CE07F))),
            ),
          const SizedBox(height: 12),
          _AboutSection(book: widget.book),
          const SizedBox(height: 12),
          _buildVariantsSection(),
          const SizedBox(height: 12),
          _HighlightSection(book: widget.book),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Language Tabs + Read/Listen/Watch Buttons ──────────────────────────

  Widget _buildLanguageAndActions() {
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
          // Language chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _variants.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final lang = _variants[index].language;
                final isSelected = lang == _selectedLanguage;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF042153) : Colors.white,
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
                        color:
                            isSelected ? Colors.white : const Color(0xFF042153),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons based on selected variant's formats
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = <Widget>[];

    // Read (ebook)
    if (_hasFormat('ebook')) {
      final format = _getFormat('ebook');
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
                'title': widget.book.title,
                'language': _selectedLanguage ?? 'en',
              },
            );
          }
        },
      ));
    }

    // Request (hardcover/paperback)
    if (_hasFormat('hardcover') || _hasFormat('paperback')) {
      buttons.add(_actionBtn(
        icon: Icons.menu_book_rounded,
        label: 'Request',
        color: const Color(0xFF4F46E5),
        onTap: () {
          if (!_checkPrimeOrPrompt(context)) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookRequestFormPage(
                bookId: widget.book.id,
                bookTitle: widget.book.title,
                coverImageUrl: widget.book.coverImageUrl,
              ),
            ),
          );
        },
      ));
    }

    // Listen (audiobook)
    if (_hasFormat('audiobook')) {
      buttons.add(_actionBtn(
        icon: Icons.headphones_rounded,
        label: 'Listen',
        color: const Color(0xFFD97706),
        onTap: () {
          if (!_checkPrimeOrPrompt(context)) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Audiobook player coming soon!'),
                behavior: SnackBarBehavior.floating),
          );
        },
      ));
    }

    // Watch (videobook)
    if (_hasFormat('videobook')) {
      buttons.add(_actionBtn(
        icon: Icons.play_circle_rounded,
        label: 'Watch',
        color: const Color(0xFF7C3AED),
        onTap: () {
          if (!_checkPrimeOrPrompt(context)) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Video player coming soon!'),
                behavior: SnackBarBehavior.floating),
          );
        },
      ));
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

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

  Widget _buildVariantsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Variants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  bool canManage = false;
                  if (profileState is ProfileLoaded) {
                    final currentUser = profileState.user;
                    if (currentUser.role == 'admin' ||
                        currentUser.id == widget.book.owner.id) {
                      canManage = true;
                    }
                  }
                  if (!canManage) return const SizedBox.shrink();

                  return ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        '/book-variants',
                        arguments: _toBookCrudModel(widget.book),
                      );
                      _loadVariants();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text(
                      'Add Variant',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingVariants)
            const Center(child: CircularProgressIndicator(color: Colors.green))
          else if (_variants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No variants added yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _variants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final variant = _variants[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.language.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2939),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: variant.formats.map((format) {
                          IconData icon;
                          Color color;
                          String text = format.type.toUpperCase();

                          switch (format.type) {
                            case 'hardcover':
                              icon = Icons.menu_book_rounded;
                              color = const Color(0xFF4F46E5);
                              if (format.copies != null) {
                                text += ' (${format.copies} copies)';
                              }
                              break;
                            case 'ebook':
                              icon = Icons.book_online_rounded;
                              color = const Color(0xFF0D9488);
                              if (format.fileUrl != null) {
                                text += ' (${format.fileUrl!.split('/').last})';
                              }
                              break;
                            case 'audiobook':
                              icon = Icons.headphones_rounded;
                              color = const Color(0xFFD97706);
                              if (format.totalDuration != null) {
                                final mins = format.totalDuration! ~/ 60;
                                text += ' ($mins min)';
                              }
                              break;
                            default:
                              icon = Icons.bookmark_border_rounded;
                              color = Colors.grey;
                          }

                          return Chip(
                            avatar: Icon(icon, size: 14, color: color),
                            label: Text(
                              text,
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: color.withValues(alpha: 0.08),
                            side:
                                BorderSide(color: color.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
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
              _IconCircleButton(
                icon: Icons.bookmark_border_rounded,
                onTap: () {},
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
        child: Icon(icon, size: 20, color: const Color(0xFF1E2939)),
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
              color: Color(0xFF1E2939),
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
