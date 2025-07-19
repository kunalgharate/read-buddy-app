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
                    title: book.title,
                    writter: book.author,
                    description: book.description,
                    donator: book.ownerName ?? "Unknown",
                    ratings: "6",
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
                  ReviewWidget(
                    name: 'Rahul Srivastav',
                    timestamp: '19 April 2025\n2:36 PM',
                    review:
                        'This book shows how good design makes everyday things easy and enjoyable to use. It\'s helpful for anyone who cares about design and usability.',
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
