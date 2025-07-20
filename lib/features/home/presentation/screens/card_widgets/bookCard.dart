import 'package:flutter/material.dart';

import '../../../../books/screens/book_details_screen.dart';

class BookCard extends StatelessWidget {
  final String bookId;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String duration;
  final String imageUrl;
  final String formatUrl;
  final bool showLockIcon;
  const BookCard({
    super.key,
    required this.bookId,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.duration,
    required this.imageUrl,
    required this.formatUrl,
    this.showLockIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailsScreen(bookId: bookId),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 194,
            height: 332,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              // color: const Color(0xFFD0E1FD),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image group container
                Container(
                  width: 182,
                  height: 218,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xFFD0E1FD),
                  ),
                  child: Container(
                    width: 147,
                    height: 176,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/icons/tabler_arrow-right.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/icons/tabler_arrow-right.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Details Group
                SizedBox(
                  width: 182,
                  height: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Category + Donor
                      SizedBox(
                        width: 148,
                        height: 66,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  wordSpacing: 0,
                                  color: Color.fromRGBO(5, 46, 68, 1),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            if (showLockIcon)
                              Text(category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color.fromRGBO(20, 20, 20, 1))),
                            if (showLockIcon)
                              Text("Donated by $donor",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color.fromRGBO(20, 20, 20, 1))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Format + Duration section
                      Container(
                        width: 182,
                        height: 26,
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(44, 224, 127, 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(44, 224, 127, 1),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    formatUrl,
                                    width: 16,
                                    height: 16,
                                  ),
                                  SizedBox(width: 5),
                                  Text(format,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            // Text(duration,
                            //     style: const TextStyle(
                            //         fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
