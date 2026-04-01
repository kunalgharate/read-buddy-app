import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../category_crud/presentation/bloc/bloc/category_bloc.dart';
import '../../../donated_books/presentation/bloc/donated_books_bloc.dart';
import '../../../donated_books/presentation/bloc/donated_books_events.dart';
import '../../../donated_books/presentation/bloc/donated_books_states.dart';
import '../widgets/dashboard_box_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryState = context.watch<CategoryBloc>().state;
    final donatedBooksState = context.watch<DonatedBooksBloc>().state;

    final categoryCount =
        categoryState is CategoryLoaded ? categoryState.categories.length : 0;
    final donatedBooksCount = donatedBooksState is DonatedBooksLoaded
        ? donatedBooksState.donatedBooks.length
        : 0;
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
                children: [
                  DashboardBoxWidget(
                    title: 'Books Donated',
                    count: donatedBooksCount,
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/donated-books');
                    },
                  ),
                  DashboardBoxWidget(
                    title: 'Books Request',
                    count: 8,
                    color: Colors.redAccent,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'New Users',
                    count: 5,
                    color: Colors.lightBlue,
                    onPressed: () {},
                  ),
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
                children: [
                  DashboardBoxWidget(
                    title: 'Categories',
                    count: categoryCount,
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
                      }),
                  DashboardBoxWidget(
                    title: 'Donations',
                    count: 318,
                    icon: Icons.card_giftcard,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Request',
                    count: 12,
                    icon: Icons.list_alt,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Users',
                    count: 12,
                    icon: Icons.people,
                    onPressed: () {},
                  ),
                  DashboardBoxWidget(
                    title: 'Banner',
                    count: 12,
                    icon: Icons.people,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/banner');
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
