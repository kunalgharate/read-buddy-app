import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/books/presentation/widgets/book_header_widget.dart';

import '../../bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import '../presentation/bloc/review/review_bloc.dart';
import '../presentation/bloc/review/review_event.dart';
import '../presentation/bloc/review/review_state.dart';
import '../presentation/widgets/about_book_widget.dart';
import '../presentation/widgets/action_buttons_widget.dart';
import '../presentation/widgets/highlight_widget.dart';
import '../presentation/widgets/review_widget.dart';
import '../presentation/widgets/similar_books_widget.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookCrudBloc>().add(LoadBookCrudById(id: widget.bookId));
    context.read<ReviewBloc>().add(FetchReviews()); //widget.bookId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<BookCrudBloc, BookCrudState>(builder: (context, state) {
        if (state is BookCrudLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookCrudDetailLoaded) {
          final book = state.book;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BookHeaderWidget(
                    title: book.title,
                    writter: book.author,
                    description: book.description,
                    donator: book.ownerName ?? "Unknown",
                    ratings: "6",
                    coverImageUrl: book.coverImageUrl,
                  ),
                  AboutBookWidget(
                    about: book.description,
                  ),
                  HighlightWidget(
                    category: book.category,
                    author: book.author,
                    genre: book.genre,
                    bookLang: book.language,
                    pages: book.pages?.toString() ?? 'N/A',
                    fromat: book.format,
                  ),
                  BlocBuilder<ReviewBloc, ReviewState>(
                    builder: (context, state) {
                      if (state is ReviewLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ReviewLoaded) {
                        if (state.reviews.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No reviews yet.'),
                          );
                        }
                        return Column(
                          children: state.reviews.map((review) {
                            return ReviewWidget(
                              name: review.reviewerName,
                              timestamp:
                                  '', // Update if your model has timestamp
                              review: review.comment,
                              imageUrl: review
                                  .reviewerImageUrl, // You may need to add this to ReviewWidget
                              rating: review
                                  .rating, // Also add this to ReviewWidget if missing
                            );
                          }).toList(),
                        );
                      } else if (state is ReviewError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SimilarBooksWidget(),
                  ActionButtonsWidget(),
                ],
              ),
            ),
          );
        } else if (state is BookCrudError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      }),
      bottomNavigationBar: Row(
        children: [],
      ),
    );
  }
}
