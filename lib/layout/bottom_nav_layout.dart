import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:read_buddy_app/features/books/presentation/pages/book_page.dart';
import 'package:read_buddy_app/features/home/presentation/pages/home_page.dart';
import 'package:read_buddy_app/features/mybook/presentation/mybook.dart';

class BottomNavLayout extends StatefulWidget {
  const BottomNavLayout({super.key});

  @override
  State<BottomNavLayout> createState() => _BottomNavLayoutState();
}

class _BottomNavLayoutState extends State<BottomNavLayout> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    BookPage(),
    Mybook(),
    // DonationPage(),
  ];

  final List<String> labels = ["Home", "Category", "MyBook", "Donate"];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / labels.length;
    final labelPosition = itemWidth * currentIndex + itemWidth / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main content
          pages[currentIndex],

          // Curved Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              index: currentIndex,
              height: 60,
              backgroundColor: Colors.transparent,
              color: const Color.fromARGB(255, 3, 62, 91),
              buttonBackgroundColor: Colors.green,
              animationDuration: const Duration(milliseconds: 300),
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: const [
                Icon(Icons.home, size: 28, color: Colors.white),
                Icon(Icons.category, size: 28, color: Colors.white),
                Icon(Icons.book, size: 28, color: Colors.white),
                Icon(Icons.gif_outlined, size: 28, color: Colors.white),
              ],
            ),
          ),

          // Label aligned below selected icon
          Positioned(
            bottom: 0,
            left: labelPosition - 20, // Adjust to center the label
            child: Text(
              labels[currentIndex],
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
