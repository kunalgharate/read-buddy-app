import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your WishlistCubit and state
import 'package:read_buddy_app/features/books/presentation/bloc/wishlist_bloc.dart';
// Import your wishlist book entity model

class BottomSheetCart extends StatelessWidget {
  const BottomSheetCart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final wishlistBooks = state.books;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        padding: const EdgeInsets.only(top: 8),
                        itemBuilder: (context, index) {
                          final book = wishlistBooks[index]; // Single book item
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.bookimage,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover, // Book image
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40), // Fallback image
                                ),
                              ),
                              title: Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ), // Book title
                              subtitle: Text(
                                "Category: ${book.bookCategory.category_name}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ), // Optional: book category
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                tooltip: 'Remove from Wishlist',
                                onPressed: () {
                                  context
                                      .read<WishlistCubit>()
                                      .removeBook(book);
                                },
                              ),
                            ),
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
