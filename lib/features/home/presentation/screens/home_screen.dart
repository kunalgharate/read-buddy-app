import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/category_tab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/donation_tab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/main_tab.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';

import 'package:read_buddy_app/features/profile/presentation/pages/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildLibrarianDrawer(context),
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('ReadBuddy'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notification'),
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notifications',
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          MainTab(
              onDonatePressed: () =>
                  Navigator.pushNamed(context, '/donate-money')),
          const CategoryTab(),
          BlocProvider(
            create: (_) => getIt<DonateBookBloc>(),
            child: const DonationTab(),
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  /// Returns a drawer only if the user is a librarian, otherwise null.
  Widget? _buildLibrarianDrawer(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) return null;

    final role = profileState.user.role;
    if (role != 'librarian') return null;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.local_library,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profileState.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Librarian',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primary),
              title: const Text('Librarian Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/librarian/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: AppColors.primary),
              title: const Text('Book Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/librarian/requests');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: AppColors.primary),
              title: const Text('Donations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/librarian/donations');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Back to Home'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
