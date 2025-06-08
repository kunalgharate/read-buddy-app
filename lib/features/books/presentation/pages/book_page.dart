// lib/features/books/presentation/pages/book_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../widgets/book_list_item.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReadBuddyLoginScreen()));
          },
          child: const Text("Login")),
    ];

    context.read<BookBloc>().add(LoadBooks());
    return Scaffold(
      appBar: AppBar(title: const Text('Ready Buddy Books'), actions: actions),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          switch (state) {
            case BookInitial():
              return Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddBookPage()));
                      },
                      child: const Text("Add Book")),
                  const Center(child: Text('No books loaded.')),
                ],
              );

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

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  @override
  Widget build(BuildContext context) {
    return const Text('Add book');
  }
}
