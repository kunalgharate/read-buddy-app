// Fourth Widget

import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/books/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/books/screens/all_reviews_page.dart';

class ReviewWidget extends StatelessWidget {
  // final String image;
  final String name;
  final String timestamp;
  final String review;
  final String imageUrl;
  final double rating;
  final List<ReviewEntity> allReviews;
  final bool showTitleAndMoreButton;

  const ReviewWidget({
    super.key,
    // required this.image,
    required this.name,
    required this.timestamp,
    required this.review,
    required this.imageUrl,
    required this.rating,
    required this.allReviews,
    this.showTitleAndMoreButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16), // Added padding
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 240, 242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitleAndMoreButton)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Review This Book',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllReviewsPage(reviews: allReviews),
                          ),
                        );
                      },
                      child: Text(
                        'More',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 50),
                          )
                        : const Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        // 'Rahul Srivastav',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < rating.floor()) {
                                return const Icon(Icons.star,
                                    color: Colors.amber, size: 18);
                              } else if (index == rating.floor() &&
                                  (rating - rating.floor()) >= 0.5) {
                                return const Icon(Icons.star_half,
                                    color: Colors.amber, size: 18);
                              } else {
                                return const Icon(Icons.star_border,
                                    color: Colors.amber, size: 18);
                              }
                            }),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review,
                        // 'This book shows how good design makes everyday things easy and enjoyable to use. It\'s helpful for anyone who cares about design and usability.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
