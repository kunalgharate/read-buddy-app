// lib/features/books/presentation/pages/book_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/books_list_page.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/addbook_stepper.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/add_category.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../widgets/book_list_item.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final List<String> categories = [
    'All',
    'Trending',
    'Fiction',
    'Non Fiction',
    'Biography',
    'Comics'
  ];

  final Set<String> selectedCategories = {'All'};

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          },
          child: const Text("Login")),
    ];

    context.read<BookBloc>().add(LoadBooks());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready Buddy '),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCategory()),
                );
              },
              icon: const Icon(Icons.category, size: 18, color: Colors.white),
              label: const Text('+ Category',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(20, 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>

                            //CategoryListPage()
                            const BooksListPage()));
              },
              icon: const Icon(Icons.book, size: 18, color: Colors.white),
              label:
                  const Text('+ Book', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(20, 40),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search any Books',
                  filled: true,
                  fillColor: const Color(0xFFF1F1F1),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.qr_code))
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: 8,
              //runSpacing: 5,
              children: categories.map((category) {
                final isSelected = selectedCategories.contains(category);

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: Colors.white,
                  checkmarkColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: BlocBuilder<BookBloc, BookState>(
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
                                        builder: (context) =>
                                            const BookStepper()
                                        // AddBookPage(
                                        //   onContinue: () {},
                                        // )
                                        ));
                              },
                              child: const Text("Add Book")),
                          const Center(child: Text('No books loaded.')),
                        ],
                      );

                    case BookLoading():
                      return const Center(child: CircularProgressIndicator());

                    case BookLoaded(:final books):
                      return GridView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 80), // 👈 Add space for bottom nav
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) =>
                            BookListItem(book: books[index]),
                      );

                    case BookError(:final message):
                      return Center(child: Text(message));
                  }
                },
              ),
            ),
          ],
        ),
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
