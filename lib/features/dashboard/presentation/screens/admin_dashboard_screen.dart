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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _countsFuture = _fetchDashboardCounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    // Build the full set of navigation tiles as data so they can be filtered
    // by the search box. Each entry carries its title, count and destination.
    final allTiles = <_DashboardTile>[
      _DashboardTile(
        title: 'Categories',
        count: counts['categories'] ?? 0,
        icon: Icons.category,
        route: '/category',
      ),
      _DashboardTile(
        title: 'Books',
        count: counts['books'] ?? 0,
        icon: Icons.book,
        route: '/books',
      ),
      _DashboardTile(
        title: 'Donations',
        count: counts['donations'] ?? 0,
        icon: Icons.card_giftcard,
        route: '/donated-books',
      ),
      _DashboardTile(
        title: 'Request',
        count: counts['requests'] ?? 0,
        icon: Icons.list_alt,
        route: '/admin-book-requests',
      ),
      _DashboardTile(
        title: 'Users',
        count: counts['users'] ?? 0,
        icon: Icons.people,
        route: '/admin-users',
      ),
      const _DashboardTile(
        title: 'Banner',
        count: 0,
        icon: Icons.image,
        route: '/banner',
      ),
      const _DashboardTile(
        title: 'Questions',
        count: 0,
        icon: Icons.quiz,
        route: '/questions',
      ),
      const _DashboardTile(
        title: 'Upcoming Pickups',
        count: 0,
        icon: Icons.local_shipping_outlined,
        route: '/admin-upcoming-pickups',
      ),
      const _DashboardTile(
        title: 'Libraries',
        count: 0,
        icon: Icons.local_library,
        route: '/libraries',
      ),
      const _DashboardTile(
        title: 'Returns',
        count: 0,
        icon: Icons.assignment_return,
        route: '/admin-return-requests',
      ),
    ];

    // The horizontal quick-stats boxes are their own navigation destinations
    // (distinct titles/routes from the grid tiles). They are only rendered in
    // the dedicated row when NOT searching, so previously searching for e.g.
    // "New Users" or "Books Donated" found nothing. Model them as tiles too so
    // they are discoverable via search while still keeping their live counts.
    final quickStatTiles = <_DashboardTile>[
      _DashboardTile(
        title: 'Books Donated',
        count: counts['donations'] ?? 0,
        icon: Icons.card_giftcard,
        route: '/admin-donations',
      ),
      _DashboardTile(
        title: 'Books Request',
        count: counts['requests'] ?? 0,
        icon: Icons.list_alt,
        route: '/admin-book-requests',
      ),
      _DashboardTile(
        title: 'New Users',
        count: counts['users'] ?? 0,
        icon: Icons.people,
        route: '/admin-users',
      ),
    ];

    final query = _searchQuery.trim().toLowerCase();
    // When searching, include the quick-stat destinations in the searchable
    // set so every dashboard navigation box is findable. When not searching,
    // they are shown in their dedicated horizontal row instead (below) and are
    // therefore excluded here to avoid duplicates.
    final searchableTiles =
        query.isEmpty ? allTiles : [...allTiles, ...quickStatTiles];
    final filteredTiles = query.isEmpty
        ? allTiles
        : searchableTiles
            .where((t) => t.title.toLowerCase().contains(query))
            .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search',
              border: const OutlineInputBorder(),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // The horizontal quick-stats row is only shown when not searching
          // so search results stay focused on the matching tiles.
          if (query.isEmpty) ...[
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
          ],
          Expanded(
            child: filteredTiles.isEmpty
                ? Center(
                    child: Text(
                      'No matches for "$_searchQuery"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: filteredTiles
                        .map(
                          (tile) => DashboardBoxWidget(
                            title: tile.title,
                            count: tile.count,
                            icon: tile.icon,
                            onPressed: () {
                              Navigator.of(context).pushNamed(tile.route);
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Simple data holder for a dashboard navigation tile so the grid can be
/// filtered by the search box.
class _DashboardTile {
  final String title;
  final int count;
  final IconData icon;
  final String route;

  const _DashboardTile({
    required this.title,
    required this.count,
    required this.icon,
    required this.route,
  });
}
