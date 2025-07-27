// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:read_buddy_app/features/books/presentation/bloc/wishlist_bloc.dart';

// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Wishlist',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: BlocBuilder<WishlistCubit, WishlistState>(
//         builder: (context, state) {
//           if (state.books.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Your wishlist is empty!',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: state.books.length,
//             itemBuilder: (context, index) {
//               final book = state.books[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12.0),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   leading: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       book.bookimage,
//                       width: 50,
//                       height: 70,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           const Icon(Icons.broken_image, size: 40),
//                     ),
//                   ),
//                   title: Text(
//                     book.title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "Category: ${book.bookCategory.category_name}",
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete_outline,
//                         color: Colors.redAccent),
//                     tooltip: 'Remove from Wishlist',
//                     onPressed: () {
//                       context.read<WishlistCubit>().removeBook(book);
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
