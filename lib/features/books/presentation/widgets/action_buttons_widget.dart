// Sixth Widget -
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/books/screens/book_details_screen.dart';
import '../../data/models/book_model.dart';
import '../../domain/entities/book.dart';
import '../bloc/wishlist_bloc.dart';
import '../pages/request_book.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final String donor;
  final String genre;
  const ActionButtonsWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.donor,
    required this.genre,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  final book = Book(
                    id: id,
                    title: capitalizeWords(title),
                    bookCategory: BookCategory(
                        id: id, category_name: capitalizeWords(genre)),
                    bookimage: imageUrl,
                    bookId: '',
                  );

                  context.read<WishlistCubit>().addBook(book);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF374151),
                ),
                child: const Text(
                  'Add to WishList',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(5, 5, 5, 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestBookPage(
                        title: title,
                        imageUrl: imageUrl,
                        donor: donor,
                        genre: genre,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2CE07F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Request to Book',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(5, 46, 68, 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
