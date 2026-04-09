import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/add_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/update_category.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded) {
                    if (state.categories.isEmpty) {
                      return const Center(child: Text("No categories found."));
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: state.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildCategoryCard(state.categories[index], context);
                      },
                    );
                  } else if (state is CategoryError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2CE07F),
        shape: const CircleBorder(),
        tooltip: 'Add Category',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddCategory()));
        },
        child: const Icon(Icons.add, color: Color(0xFF052E44), size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void updatedialog(CategoryEntity category) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF052E44)),
                  title: const Text('Edit Category'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateCategoryPage(category: category),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Category',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(category.id);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Category',
          style: TextStyle(color: Color(0xFF052E44), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF052E44))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryEntity category, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF262626), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: category.imageUrl,
              width: 70,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (category.parentCategoryName != null)
                      _badge(category.parentCategoryName!)
                    else
                      _badge('No Parent'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Description: ${category.description?.isNotEmpty == true ? category.description! : 'None'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF052E44),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => updatedialog(category),
            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF141414)),
          ),
        ],
      ),
    ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2CE07F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF052E44),
        ),
      ),
    );
  }


}
