import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../widgets/dashboard_box_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        actions: [
          //logout action
          IconButton(
            onPressed: () {
              final secureStorage = getIt<SecureStorageUtil>();
              secureStorage.clearAll();
              Navigator.pushReplacementNamed(context, '/signin');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage books, categories and users',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
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
                children: const [
                  DashboardBoxWidget(title: 'Books Donated', count: 5, color: Colors.grey),
                  DashboardBoxWidget(title: 'Books Request', count: 8, color: Colors.redAccent),
                  DashboardBoxWidget(title: 'New Users', count: 5, color: Colors.lightBlue),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.85, // Adjust this to give enough height
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: const [
                  DashboardBoxWidget(title: 'Categories', count: 12, icon: Icons.category),
                  DashboardBoxWidget(title: 'Books', count: 236, icon: Icons.book),
                  DashboardBoxWidget(title: 'Donations', count: 318, icon: Icons.card_giftcard),
                  DashboardBoxWidget(title: 'Request', count: 12, icon: Icons.list_alt),
                  DashboardBoxWidget(title: 'Users', count: 12, icon: Icons.people),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
