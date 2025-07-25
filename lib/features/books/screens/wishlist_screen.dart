import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/wishlist_cubit.dart';

// Use the Book model from wishlist_cubit.dart

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Book> availableBooks = [
      const Book(
          id: '1', title: 'The Great Gatsby', author: 'F. Scott Fitzgerald'),
      const Book(id: '2', title: 'To Kill a Mockingbird', author: 'Harper Lee'),
      const Book(id: '3', title: '1984', author: 'George Orwell'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // Wrap the entire body in BlocListener to show SnackBar when item is added
      body: BlocListener<WishlistCubit, WishlistState>(
        listenWhen: (previous, current) =>
            current.items.length > previous.items.length,
        listener: (context, state) {
          final lastBookTitle = state.items.last.title;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // THIS IS THE CONTROLLER: We set the duration to be longer.
              // It will now stay on screen for 8 seconds instead of the default 4.
              duration: const Duration(seconds: 8),
              content: Text("'$lastBookTitle' was added to your wishlist!"),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              // OPTIONAL BUT RECOMMENDED: Add a button to let the user close it manually.
              action: SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        },
        child: Column(
          children: [
            // SECTION 1: List of available books to add
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Books',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  for (var book in availableBooks)
                    ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      trailing: ElevatedButton(
                        onPressed: () {
                          context.read<WishlistCubit>().addToWishlist(book);
                        },
                        child: const Text('Add to Wishlist'),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // SECTION 2: The actual wishlist
            Expanded(
              child: BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Your wishlist is empty!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.favorite, color: Colors.redAccent),
                        title: Text(item.title),
                        subtitle: Text(item.author),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.grey),
                          tooltip: 'Remove from Wishlist',
                          onPressed: () {
                            context
                                .read<WishlistCubit>()
                                .removeFromWishlist(item);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
