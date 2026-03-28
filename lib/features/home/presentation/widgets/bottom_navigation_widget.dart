import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      height: 60,
      backgroundColor: Colors.transparent,
      color: const Color.fromARGB(255, 3, 62, 91),
      buttonBackgroundColor: Colors.green,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onTap,
      items: [
        SvgPicture.asset('assets/icons/home.svg',
            width: 28, height: 28, color: Colors.white),
        SvgPicture.asset('assets/icons/categories.svg',
            width: 28, height: 28, color: Colors.white),
        SvgPicture.asset('assets/icons/donation.svg',
            width: 28, height: 28, color: Colors.white),
        SvgPicture.asset('assets/icons/person.svg',
            width: 28, height: 28, color: Colors.white),
      ],
    );
  }
}
