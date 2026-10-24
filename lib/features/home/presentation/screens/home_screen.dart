import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/utils/access_control.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/bottom_navigation_widget.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/category_tab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/donation_tab.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/main_tab.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/features/profile/presentation/pages/screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    // Refresh donation stats every time user switches to Donate tab
    if (index == 2) {
      context.read<DonateBookBloc>().add(LoadDonationStats());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('ReadBuddy'),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              ),
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
                Navigator.pushNamed(context, '/donate-money'),
          ),
          const CategoryTab(),
          const DonationTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }

  /// App drawer for all users with role-specific items.
  Widget? _buildAppDrawer(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final user = profileState is ProfileLoaded ? profileState.user : null;
    final role = user?.role ?? 'user';

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
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'ReadBuddy User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.email ?? role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.book_online, color: AppColors.primary),
                    title: const Text('My Requests'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/my-requests');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('My Orders'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/my-orders');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Saved Addresses'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/addresses');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text('Wishlist'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/wishlist');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notification');
                    },
                  ),
                  if (role == 'librarian') ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                      child: Text(
                        'LIBRARIAN MENU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.dashboard, color: AppColors.primary),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/librarian/dashboard');
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.list_alt, color: AppColors.primary),
                      title: const Text('Requests'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/librarian/requests');
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
                      ),
                      title: const Text('Donations'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/librarian/donations');
                      },
                    ),
                  ],
                  if (AccessControl.isAdmin(role)) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                      child: Text(
                        'ADMIN MENU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.primary,
                      ),
                      title: const Text('Admin Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin');
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.people, color: AppColors.primary),
                      title: const Text('Manage Users'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin-users');
                      },
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
