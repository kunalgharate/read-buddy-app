import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/donated_books_bloc.dart';
import '../bloc/donated_books_events.dart';
import '../bloc/donated_books_states.dart';
import '../widgets/donated_book_card.dart';

class DonatedBooksPage extends StatefulWidget {
  const DonatedBooksPage({super.key});

  @override
  State<DonatedBooksPage> createState() => _DonatedBooksPageState();
}

class _DonatedBooksPageState extends State<DonatedBooksPage> {
  @override
  void initState() {
    context.read<DonatedBooksBloc>().add(LoadDonatedBooks());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donated Books',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          // it is currently not working
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Container(
          //     height: 44,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: const Color(0xFF052E44)),
          //     ),
          //     child: const TextField(
          //       decoration: InputDecoration(
          //         hintText: 'Search Category',
          //         hintStyle: TextStyle(color: Color(0xFF262626), fontSize: 14),
          //         prefixIcon: Icon(Icons.search, color: Color(0xFF262626)),
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.symmetric(vertical: 12),
          //       ),
          //     ),
          //   ),
          // ),

          // Book list
          Expanded(
            child: BlocBuilder<DonatedBooksBloc, DonatedBooksState>(
              builder: (context, state) {
                if (state is DonatedBooksLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DonatedBooksLoaded) {
                  if (state.donatedBooks.isEmpty) {
                    return const Center(child: Text('No donated books found.'));
                  }
                  return ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    itemCount: state.donatedBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        DonatedBookCard(book: state.donatedBooks[index]),
                  );
                }

                if (state is DonatedBooksLoadingError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
