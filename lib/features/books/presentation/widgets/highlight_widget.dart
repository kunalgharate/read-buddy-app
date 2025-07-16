// Third Widget
<<<<<<< Updated upstream
import 'dart:ui';
=======
>>>>>>> Stashed changes

import 'package:flutter/material.dart';

class HighlightWidget extends StatelessWidget {
  final String category;
  final String author;
  final String genre;
  final String bookLang;
  final String pages;
  final String fromat;
  const HighlightWidget({
    super.key,
    required this.category,
    required this.author,
    required this.genre,
    required this.bookLang,
    required this.pages,
    required this.fromat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 240, 242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highlight',
            style: TextStyle(
<<<<<<< Updated upstream
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
=======
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(5, 46, 68, 1)),
>>>>>>> Stashed changes
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHighlightItem('Book Type', category),
              _buildHighlightItem('Author', author),
              _buildHighlightItem('Genre', genre),
              _buildHighlightItem('Language', bookLang),
              _buildHighlightItem('Total Pages', pages),
              _buildHighlightItem('Book Format', fromat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label - ',
            style: TextStyle(
<<<<<<< Updated upstream
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
=======
              fontSize: 14,
              color: Color.fromRGBO(20, 20, 20, 1),
              fontWeight: FontWeight.w400,
              wordSpacing: 0,
>>>>>>> Stashed changes
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
<<<<<<< Updated upstream
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
=======
                fontSize: 14,
                color: Color.fromRGBO(20, 20, 20, 1),
                fontWeight: FontWeight.w400,
                wordSpacing: 0,
>>>>>>> Stashed changes
              ),
            ),
          ),
        ],
      ),
    );
  }
}
