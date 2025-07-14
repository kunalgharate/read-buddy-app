// Third Widget
import 'dart:ui';

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
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
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
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
