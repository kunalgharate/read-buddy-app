import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/CategoryTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/DonationTab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/MainTab.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/app_preferences.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../books/presentation/pages/book_page.dart';
import '../../../profile/presentation/pages/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MainTab(),
    BookPage(),
    DonationTab(),
    ProfileScreen(),
  ];

  Future<void> _logout() async {
    await getIt<SecureStorageUtil>().clearAll();
    await AppPreferences.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/signin', (_) => false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('Read Buddy'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _showLogoutDialog,
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
