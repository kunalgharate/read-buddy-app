import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/books/presentation/widgets/book_header_widget.dart';

import '../../bookcrud/presentation/bloc/bloc/book_crud_event.dart';
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
                    title: capitalizeWords(book.title),
                    writter: capitalizeWords(book.author),
                    description: capitalizeFirstLetter(book.description),
                    donator: capitalizeFirstLetter(book.ownerName ?? "Unknown"),
                    ratings: "6",
                    coverImageUrl: book.coverImageUrl,
                  ),
                  AboutBookWidget(
                    about: capitalizeFirstLetter(book.description),
                  ),
                  HighlightWidget(
                    category: capitalizeWords(book.category),
                    author: capitalizeWords(book.author),
                    genre: capitalizeWords(book.genre),
                    bookLang: capitalizeWords(book.language),
                    pages: book.pages?.toString() ?? 'N/A',
                    fromat: capitalizeWords(book.format),
                  ),
                  // Reviews section - placeholder for future implementation
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Reviews feature coming soon...',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
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
