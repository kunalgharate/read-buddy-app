// lib/features/books/presentation/widgets/book_list_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../screens/book_details_screen.dart';
import '../bloc/review/review_bloc.dart';
import '../bloc/review/review_event.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // The corrected navigation logic
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              // Use BlocProvider to create and provide the ReviewBloc for this route
              return BlocProvider(
                create: (context) => ReviewBloc(
                    getReviews: getIt<
                        GetReviewsUseCase>()) // Pass GetReviewsUseCase instance
                  ..add(FetchReviews(
                      book.id)), // Dispatch an initial event to load reviews
                child: BookDetailsScreen(bookId: book.id),
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black), // visible border
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12), bottom: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: book.bookimage,
                  height: 200,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.title,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.bookCategory.category_name,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
