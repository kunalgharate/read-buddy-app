import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';

import '../../../books/presentation/bloc/book_bloc.dart';
import '../../../books/presentation/bloc/book_event.dart';
import '../../../books/presentation/bloc/book_state.dart';
import '../../../books/presentation/widgets/book_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => const SignInScreen()));
          },
          child: const Text("Login")),
    ];

    context.read<BookBloc>().add(LoadBooks());
    return Scaffold(
      appBar: AppBar(title: const Text('Ready Buddy'), actions: actions),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          switch (state) {
            case BookInitial():
              return Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const AddBookPage()));
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
    bottomNavigationBar: BottomNavWidget(),
    );
  }
}


