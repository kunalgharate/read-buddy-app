import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_state.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/addbook_stepper.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/book_collection.dart';

class BooksListPage extends StatefulWidget {
  const BooksListPage({super.key});

  @override
  State<BooksListPage> createState() => _BooksListPageState();
}

class _BooksListPageState extends State<BooksListPage> {
  TextEditingController searchBookController = TextEditingController();

  @override
  void initState() {
    context.read<BookCrudBloc>().add(LoadBookCrudList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Book'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextField(
                cursorColor: Colors.grey,
                controller: searchBookController,
                decoration: InputDecoration(
                    hintText: 'Search Book',
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(child: BlocBuilder<BookCrudBloc, BookCrudState>(
              builder: (context, state) {
                switch (state) {
                  case BookCrudLoading():
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case BookCrudListLoaded(:final booksCollection):
                    return ListView.builder(
                        //physics: const NeverScrollableScrollPhysics(),
                        itemCount: booksCollection.length,
                        itemBuilder: (context, index) {
                          final bookCollectionItem = booksCollection[index];
                          return BooksCollection(
                            bookcollection: bookCollectionItem,
                          );
                        });
                  case BookCrudError(:final message):
                    return Center(
                      child: Text(message),
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            )),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color.fromARGB(255, 96, 177, 228),
        shape: CircleBorder(),
        tooltip: 'Add Book',
        onPressed: () {
          // Your action
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>

                      //CategoryListPage()
                      const BookStepper()));
        },
        child: const Center(
          child: Text(
            'Add Book',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
