import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your WishlistCubit and state
import 'package:read_buddy_app/features/books/presentation/bloc/wishlist_bloc.dart';
// Import your wishlist book entity model

class BottomSheetCart extends StatelessWidget {
  const BottomSheetCart({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds UI when WishlistCubit state changes
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final wishlistBooks = state.books; // Get the current wishlist items

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // Padding inside bottom sheet
          height: MediaQuery.of(context).size.height *
              0.6, // Bottom sheet takes 60% of screen height
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(16)), // Rounded top corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wishlist',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold), // Title style
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Navigator.pop(context), // Close the bottom sheet
                  ),
                ],
              ),
              const Divider(), // Separator line below header

              // Body: Book List or Empty Text
              Expanded(
                child: wishlistBooks.isEmpty
                    ? const Center(
                        child: Text('No books in wishlist'),
                      )
                    : ListView.builder(
                        itemCount:
                            wishlistBooks.length, // Number of wishlist items
                        itemBuilder: (context, index) {
                          final book = wishlistBooks[index]; // Single book item
                          return ListTile(
                            leading: Image.network(
                              book.bookimage,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover, // Book image
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image), // Fallback image
                            ),
                            title: Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ), // Book title
                            subtitle: Text(
                              "Category: ${book.bookCategory.category_name}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ), // Optional: book category
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
