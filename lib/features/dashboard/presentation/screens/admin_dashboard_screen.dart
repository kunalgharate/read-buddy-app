import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/profile/presentation/pages/screen/profile_screen.dart';
import '../widgets/dashboard_box_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AdminDashboardBody(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBoxWidget(
                    title: 'Books Donated',
                    count: 5,
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-donations');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Books Request',
                    count: 8,
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-book-requests');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'New Users',
                    count: 5,
                    color: Colors.lightBlue,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-users');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  DashboardBoxWidget(
                    title: 'Categories',
                    count: 12,
                    icon: Icons.category,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/category');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Books',
                    count: 236,
                    icon: Icons.book,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/books');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Donations',
                    count: 318,
                    icon: Icons.card_giftcard,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/donated-books');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Request',
                    count: 12,
                    icon: Icons.list_alt,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-book-requests');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Users',
                    count: 12,
                    icon: Icons.people,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-users');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Banner',
                    count: 12,
                    icon: Icons.image,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/banner');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Questions',
                    count: 0,
                    icon: Icons.quiz,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/questions');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Upcoming Pickups',
                    count: 0,
                    icon: Icons.local_shipping_outlined,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-book-requests');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Libraries',
                    count: 0,
                    icon: Icons.local_library,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/libraries');
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
