import 'package:flutter/material.dart';

import '../../../../books/screens/book_details_screen.dart';

class RecommendedBookCard extends StatelessWidget {
  final String bookId;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String duration;
  final String imageUrl;
  final String formatUrl;

  const RecommendedBookCard({
    super.key,
    required this.bookId,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.duration,
    required this.imageUrl,
    required this.formatUrl,
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
      child: Container(
        width: double.infinity,
        height: 356, //  Total fixed height
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
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
            // image Section with Lock Icon
            Stack(
              children: [
                Container(
                  width: 182,
                  height: 218, //Fixed image height
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0E1FD),
                    borderRadius: BorderRadius.circular(6),
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

                // Lock icon — UNCHANGED
                Positioned(
                  top: 171,
                  left: 135,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_open,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Book Details Section (FIXED height + structure)
            SizedBox(
              width: 182,
              height: 120, // Increased from 96 → 120 to match your layout
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Metadata block
                  Expanded(
                    //Now fills up to 94px (120 - 26)
                    child: SizedBox(
                      width: 148,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, //Balanced vertical spacing
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Color.fromRGBO(5, 46, 68, 1),
                            ),
                          ),
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              wordSpacing: 0,
                              fontFamily: 'popins',
                              color: Color.fromRGBO(20, 20, 20, 1),
                            ),
                          ),
                          Text(
                            "Donated by $donor",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              wordSpacing: 0,
                              fontFamily: 'popins',
                              color: Color.fromRGBO(20, 20, 20, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 4), // Optional buffer between text & audio row

                  // Format + Duration row pinned to bottom
                  SizedBox(
                    height: 26, //Fixed height per your design
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
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
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  formatUrl,
                                  height: 16,
                                  width: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  format,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
