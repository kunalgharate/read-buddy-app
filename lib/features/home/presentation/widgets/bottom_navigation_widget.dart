import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/CategoryTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/DonationTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/MainTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/ProfileTab.dart';

import '../../../books/presentation/pages/book_page.dart';


class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({super.key});

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Maintab(),
    CategoryTab(),
    DonationTab(),
    ProfileTab()
  ];

  final List<String> labels = ["Home", "Category", "Donation", "Profile"];

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
              items: [
SvgPicture.asset('assets/icons/home.svg', width: 28, height: 28, color: Colors.white),
SvgPicture.asset('assets/icons/categories.svg', width: 28, height: 28, color: Colors.white),
SvgPicture.asset('assets/icons/donation.svg', width: 28, height: 28, color: Colors.white),
SvgPicture.asset('assets/icons/person.svg', width: 28, height: 28, color: Colors.white),
              ],
            ),
          ),


          Positioned(
            bottom: 0,
            left: labelPosition - 20,
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
