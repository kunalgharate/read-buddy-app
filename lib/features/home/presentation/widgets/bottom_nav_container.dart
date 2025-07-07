import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_buddy_app/features/home/presentation/screens/home_screen.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/CategoryTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/DonationTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/MainTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/ProfileTab.dart';
import 'bottom_nav_widget.dart';

class BottomNavContainer extends StatefulWidget {
  const BottomNavContainer({super.key});

  @override
  State<BottomNavContainer> createState() => _BottomNavContainerState();
}

class _BottomNavContainerState extends State<BottomNavContainer> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    Maintab(),    // Home - index 0
    CategoryTab(),  // Category - index 1
    DonationTab(),  // Donation - index 2
    ProfileTab(),   // Profile - index 3
  ];

  final List<String> labels = ["Home", "Category", "Donation", "Profile"];

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _goToHome() {
    if (currentIndex != 0) {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Handle hardware back press
          if (currentIndex != 0) {
            // If not on home tab, go to home
            _goToHome();
          } else {
            // If already on home tab, you can either:
            // 1. Exit the app
            // 2. Show exit confirmation dialog
            // 3. Do nothing
            
            // Option 1: Exit the app
            // SystemNavigator.pop();
            
            // Option 2: Show exit confirmation (uncomment below)
            _showExitConfirmation();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Main content
            pages[currentIndex],

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Navigation Bar
                  BottomNavWidget(
                    currentIndex: currentIndex,
                    onTap: _onTabTapped,
                  ),
                  
                  // Label
                  Container(
                    height: 20,
                    alignment: Alignment.center,
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
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
