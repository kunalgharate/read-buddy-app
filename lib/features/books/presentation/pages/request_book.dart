import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:read_buddy_app/features/books/screens/book_details_screen.dart';

class RequestBookPage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String donor;
  final String genre;

  const RequestBookPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.donor,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final issueDate = DateTime.now();
    final returnDate = issueDate.add(const Duration(days: 7));
    String formatDate(DateTime date) {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    final formattedIssueDate = formatDate(issueDate);
    final formattedReturnDate = formatDate(returnDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Book',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Book Image + Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(6), // or whatever radius you need
                  child: Image.network(
                    imageUrl,
                    width: 140,
                    height: 180,
                    // fit: BoxFit.cover,
                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 149,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(capitalizeWords(title),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                          )),
                      const SizedBox(height: 6),
                      Text(
                        "Donated by: ${capitalizeWords(donor)}",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          wordSpacing: 0,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Genre: ${capitalizeWords(genre)}",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          wordSpacing: 0,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // Book Condition Info

            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 77,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0x99EAEAEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Issue Date:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        formattedIssueDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Return Date:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        formattedReturnDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Note

            Container(
              width: double.infinity,
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD0E1FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/error_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12), // gap between icon and text
                  const Expanded(
                    child: Text(
                      "If your return date has passed, you'll be charged ₹20 for an extra 5 days.",
                      style: TextStyle(
                        color: Color(0xFF262626),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'poppins',
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Action Buttons
            SizedBox(
              height: 43,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deliver to me selected')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CE07F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Deliver to Me',
                  style: TextStyle(
                    color: Color.fromRGBO(5, 46, 68, 1),
                    wordSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: 'poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 43,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Collect from library selected')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF052E44)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Collect from Library',
                  style: TextStyle(
                    color: Color(0xFF052E44),
                    wordSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: 'poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
