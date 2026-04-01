import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/add_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/widgets/category_card_widget.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Category',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CategoryError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is CategoryLoaded) {
                    final categories = state.categories;

                    if (categories.isEmpty) {
                      return const Center(child: Text('No categories found.'));
                    }

                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) =>
                          CategoryCardWidget(category: categories[index]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2CE07F),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCategory()),
        ),
        label: const Text(
          'Add Category',
          style:
              TextStyle(color: Color(0xFF052E44), fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Color(0xFF052E44)),
      ),
    );
  }
}
