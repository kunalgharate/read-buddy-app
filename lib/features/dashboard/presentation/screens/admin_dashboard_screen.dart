import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
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

class _AdminDashboardBody extends StatefulWidget {
  const _AdminDashboardBody();

  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody> {
  late Future<Map<String, int>> _countsFuture;

  @override
  void initState() {
    super.initState();
    _countsFuture = _fetchDashboardCounts();
  }

  Future<Map<String, int>> _fetchDashboardCounts() async {
    final response = await getIt<Dio>().get(ApiConstants.dashboardCounts);
    final data = response.data as Map<String, dynamic>;
    return {
      'books': (data['books'] as num?)?.toInt() ?? 0,
      'users': (data['users'] as num?)?.toInt() ?? 0,
      'categories': (data['categories'] as num?)?.toInt() ?? 0,
      'donations': (data['donations'] as num?)?.toInt() ?? 0,
      'requests': (data['requests'] as num?)?.toInt() ?? 0,
    };
  }

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
      body: FutureBuilder<Map<String, int>>(
        future: _countsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load dashboard data',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _countsFuture = _fetchDashboardCounts();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CE07F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final counts = snapshot.data!;
          return _buildDashboardContent(counts);
        },
      ),
    );
  }

  Widget _buildDashboardContent(Map<String, int> counts) {
    return Padding(
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
                  count: counts['donations'] ?? 0,
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-donations');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Books Request',
                  count: counts['requests'] ?? 0,
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-book-requests');
                  },
                ),
                DashboardBoxWidget(
                  title: 'New Users',
                  count: counts['users'] ?? 0,
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
                  count: counts['categories'] ?? 0,
                  icon: Icons.category,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/category');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Books',
                  count: counts['books'] ?? 0,
                  icon: Icons.book,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/books');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Donations',
                  count: counts['donations'] ?? 0,
                  icon: Icons.card_giftcard,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/donated-books');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Request',
                  count: counts['requests'] ?? 0,
                  icon: Icons.list_alt,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-book-requests');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Users',
                  count: counts['users'] ?? 0,
                  icon: Icons.people,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin-users');
                  },
                ),
                DashboardBoxWidget(
                  title: 'Banner',
                  count: 0,
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
    );
  }
}
