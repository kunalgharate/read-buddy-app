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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.logout, color: Color(0xFF00C853), size: 22),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF1E3A5F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
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
