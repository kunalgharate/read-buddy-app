import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/services/location_service.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/book_detail_page.dart';
import '../../domain/entities/library_inventory_entity.dart';
import '../bloc/library_inventory_bloc.dart';

/// A self-contained section for the home page that shows books available
/// in the user's city. Resolves city from GPS, then calls browse API.
class BooksNearYouSection extends StatefulWidget {
  const BooksNearYouSection({super.key});

  @override
  State<BooksNearYouSection> createState() => _BooksNearYouSectionState();
}

class _BooksNearYouSectionState extends State<BooksNearYouSection> {
  late final LibraryInventoryBloc _bloc;
  String? _city;
  bool _resolvingCity = true;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<LibraryInventoryBloc>();
    _resolveCity();
  }

  Future<void> _resolveCity() async {
    try {
      final locationService = LocationService.instance;
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        final address = await locationService.reverseGeocode(
          position.latitude,
          position.longitude,
        );
        if (address != null && address.city.isNotEmpty) {
          _city = address.city;
          _bloc.add(BrowseCityBooks(city: _city!));
        }
      }
    } catch (_) {
      // Location not available — section stays hidden
    }
    if (mounted) setState(() => _resolvingCity = false);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything while resolving or if city not found
    if (_resolvingCity) return const SizedBox.shrink();
    if (_city == null) return const SizedBox.shrink();

    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<LibraryInventoryBloc, LibraryInventoryState>(
        builder: (context, state) {
          if (state is LibraryInventoryLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (state is CityBooksLoaded && state.books.isNotEmpty) {
            return _BooksNearYouContent(
              city: _city!,
              books: state.books,
            );
          }

          // No books or error — hide section
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _BooksNearYouContent extends StatelessWidget {
  final String city;
  final List<CityBookEntity> books;

  const _BooksNearYouContent({required this.city, required this.books});

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimaryColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Books Near You — $city',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (_, i) => _CityBookCard(book: books[i]),
          ),
        ),
      ],
    );
  }
}

class _CityBookCard extends StatelessWidget {
  final CityBookEntity book;
  const _CityBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailPage(bookId: book.bookId),
        ),
      ),
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: book.coverImageUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: book.coverImageUrl!,
                          height: 170,
                          width: 145,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imgPlaceholder(),
                          errorWidget: (_, __, ___) => _imgPlaceholder(),
                        )
                      : _imgPlaceholder(),
                ),
                // Availability badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: book.isAvailable
                          ? Colors.green.withValues(alpha: 0.9)
                          : Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      book.isAvailable
                          ? '${book.totalAvailable} available'
                          : 'Out of Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Title & author
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${book.libraries.length} ${book.libraries.length == 1 ? 'library' : 'libraries'}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
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
        width: 145,
        decoration: const BoxDecoration(
          color: Color(0xFFE8EDF2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: const Icon(Icons.book, size: 44, color: Color(0xFFB0BEC5)),
      );
}
