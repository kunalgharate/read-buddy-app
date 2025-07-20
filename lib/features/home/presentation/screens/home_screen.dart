import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/CategoryTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/DonationTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/MainTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/ProfileTab.dart';

import '../../../auth/presentation/pages/sign_in_page.dart';
import '../../../books/presentation/bloc/book_bloc.dart';
import '../../../books/presentation/bloc/book_event.dart';
import '../../../books/presentation/bloc/book_state.dart';
import '../../../books/presentation/widgets/book_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Maintab(),
    CategoryTab(),
    DonationTab(),
    ProfileTab()
  ];

  @override
  Widget build(BuildContext context) {
    final actions = [
      ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          },
          child: const Icon(Icons.logout)),
    ];

    if (currentIndex == 0) {
      context.read<BookBloc>().add(LoadBooks());
    }
    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(title: const Text('Ready Buddy'), actions: actions)
          : null,
      body: currentIndex == 0
          ? BlocBuilder<BookBloc, BookState>(
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
            )
          : pages[currentIndex],
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                context.read<BookBloc>().add(LoadBooks());
              },
              child: const Icon(Icons.refresh),
            )
          : null,
      bottomNavigationBar: BottomNavWidget(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';

// import '../../../books/presentation/bloc/book_bloc.dart';
// import '../../../books/presentation/bloc/book_event.dart';
// import '../../../books/presentation/bloc/book_state.dart';
// import '../../../books/presentation/widgets/book_list_item.dart';
// // import 'package:read_buddy_app/core/di/injection.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final actions = [
//       ElevatedButton(
//           onPressed: () {
//             // Navigator.push(
//             //     context,
//             //     MaterialPageRoute(
//             //         builder: (context) => const SignInScreen()));
//           },
//           child: const Text("Login")),
//     ];

//     context.read<BookBloc>().add(LoadBooks());
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ready Buddy'), actions: actions),
//       body: BlocBuilder<BookBloc, BookState>(
//         builder: (context, state) {
//           switch (state) {
//             case BookInitial():
//               return Column(
//                 children: [
//                   ElevatedButton(
//                       onPressed: () {
//                         // Navigator.push(
//                         //     context,
//                         //     MaterialPageRoute(
//                         //         builder: (context) => const AddBookPage()));
//                       },
//                       child: const Text("Add Book")),
//                   const Center(child: Text('No books loaded.')),
//                 ],
//               );

//             case BookLoading():
//               return const Center(child: CircularProgressIndicator());

//             case BookLoaded(:final books):
//               return ListView.builder(
//                 itemCount: books.length,
//                 itemBuilder: (context, index) =>
//                     BookListItem(book: books[index]),
//               );

//             case BookError(:final message):
//               return Center(child: Text(message));
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.read<BookBloc>().add(LoadBooks());
//         },
//         child: const Icon(Icons.refresh),
//       ),
//       bottomNavigationBar: BottomNavWidget(),
//     );
//   }
// }