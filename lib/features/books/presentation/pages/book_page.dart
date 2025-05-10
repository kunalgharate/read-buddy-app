// lib/features/books/presentation/pages/book_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../widgets/book_list_item.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ready Buddy Books')),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          switch (state) {
            case BookInitial():
              return const Center(child: Text('No books loaded.'));

            case BookLoading():
              return const Center(child: CircularProgressIndicator());

            case BookLoaded(:final books):
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) =>
                    BookListItem(book: books[index]),
              );

            case BookError(:final message):
              return Center(child: Text(message));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<BookBloc>().add(LoadBooks());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
