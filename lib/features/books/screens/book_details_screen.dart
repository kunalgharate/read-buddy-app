import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/books/presentation/widgets/book_header_widget.dart';

import '../../bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import '../presentation/bloc/review/review_bloc.dart';
import '../presentation/bloc/review/review_event.dart';
import '../presentation/bloc/review/review_state.dart';
import '../presentation/bloc/wishlist_bloc.dart';
import '../presentation/widgets/about_book_widget.dart';
import '../presentation/widgets/action_buttons_widget.dart';
import '../presentation/widgets/bottom_sheet_cart.dart';
import '../presentation/widgets/highlight_widget.dart';
import '../presentation/widgets/view_wishlist_button_widget.dart';
import '../presentation/widgets/review_widget.dart';
import '../presentation/widgets/similar_books_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFabOnScroll = true;

  @override
  void initState() {
    super.initState();
    context.read<BookCrudBloc>().add(LoadBookCrudById(id: widget.bookId));
    context.read<ReviewBloc>().add(FetchReviews(widget.bookId));
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent;

    final bool shouldShow = !atBottom;

    if (shouldShow != _showFabOnScroll) {
      setState(() {
        _showFabOnScroll = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<BookCrudBloc, BookCrudState>(
        builder: (context, state) {
          if (state is BookCrudLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookCrudDetailLoaded) {
            final book = state.book;

            return SafeArea(
              child: BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, wishlistState) {
                  final isWishlistNotEmpty = wishlistState.books.isNotEmpty;
                  // The FAB is visible only if the wishlist has items AND the user has scrolled up from the bottom.
                  final isFabVisible = isWishlistNotEmpty && _showFabOnScroll;

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Column(
                          children: [
                            BookHeaderWidget(
                              title: capitalizeWords(book.title),
                              writter: capitalizeWords(book.author),
                              description:
                                  capitalizeFirstLetter(book.description),
                              donator: capitalizeFirstLetter(
                                  book.ownerName ?? "Unknown"),
                              ratings: "6",
                              coverImageUrl: book.coverImageUrl,
                            ),
                            AboutBookWidget(
                                about: capitalizeFirstLetter(book.description)),
                            HighlightWidget(
                              category: capitalizeWords(book.category),
                              author: capitalizeWords(book.author),
                              genre: capitalizeWords(book.genre),
                              bookLang: capitalizeWords(book.language),
                              pages: book.pages?.toString() ?? 'N/A',
                              fromat: capitalizeWords(book.format),
                            ),
                            BlocBuilder<ReviewBloc, ReviewState>(
                              builder: (context, state) {
                                if (state is ReviewLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (state is ReviewLoaded) {
                                  if (state.reviews.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No reviews yet.'),
                                    );
                                  }

                                  // Display only the first review
                                  final firstReview = state.reviews.first;

                                  return Column(
                                    children: [
                                      ReviewWidget(
                                        name: capitalizeFirstLetter(
                                            firstReview.reviewerName),
                                        timestamp: '',
                                        review: capitalizeFirstLetter(
                                            firstReview.comment),
                                        imageUrl:
                                            firstReview.reviewerImageUrl ?? '',
                                        rating: firstReview.rating ?? 0.0,
                                        allReviews: state
                                            .reviews, // Pass all reviews to ReviewWidget
                                      ),
                                    ],
                                  );
                                } else if (state is ReviewError) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(state.message,
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            SimilarBooksWidget(),
                            // The ActionButtonsWidget is now always visible at the bottom of the content.
                            ActionButtonsWidget(
                              title: book.title,
                              imageUrl: book.coverImageUrl,
                              donor: book.ownerName ?? "Unknown",
                              genre: book.genre,
                              id: book.id!,
                            ),
                            if (isWishlistNotEmpty)
                              const ViewWishlistButtonWidget(),
                          ],
                        ),
                      ),
                      if (isFabVisible)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            onPressed: () {
                              context
                                  .read<WishlistCubit>()
                                  .showMenuPermanently();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) => const BottomSheetCart(),
                              );
                            },
                            backgroundColor:
                                const Color(0xFF2CE07F).withOpacity(0.75),
                            elevation: 4.0,
                            child: Badge(
                              label:
                                  Text(wishlistState.books.length.toString()),
                              child: const Icon(
                                Icons.shopping_cart_checkout,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          } else if (state is BookCrudError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Capitalization helpers
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String capitalizeWords(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
