import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/books/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/books/presentation/widgets/review_widget.dart';

class AllReviewsPage extends StatelessWidget {
  final List<ReviewEntity> reviews;

  const AllReviewsPage({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return ReviewWidget(
            name: capitalizeWords(review.reviewerName),
            timestamp: '',
            review: capitalizeFirstLetter(review.comment),
            imageUrl: review.reviewerImageUrl ?? '',
            rating: review.rating ?? 0.0,
            allReviews: const [],
            showTitleAndMoreButton: false,
          );
        },
      ),
    );
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String capitalizeWords(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
