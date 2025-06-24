import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/delete_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/update_category.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  void initState() {
    context.read<CategoryBloc>().add(LoadCategories());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text("No categories found."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return _buildCategoryCard(category, context);
              },
            );
          } else if (state is CategoryError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void updatedialog(CategoryEntity category) async {
    print("update DIalogg messsaging");
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Expanded(
                  child: ListTile(
                    leading: Icon(Icons.update),
                    title: Text("Update Category"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UpdateCategoryPage(category: category),
                          ));
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text("Delete Category"),
                    onTap: () {
                      DeleteCategory().confirmDelete(context, category.id);
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildCategoryCard(CategoryEntity category, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Optional padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Icon
            category.imageUrl != null &&
                    ImagePickerHelper().isValidUrl(category.imageUrl)
                ? Image.network(
                    category.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 50),
                  )
                : const Icon(Icons.image_not_supported, size: 50),

            const SizedBox(width: 12), // Space between image and text

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildTag(category.parentCategory, Colors.green),
                      _buildTag("In Stock", Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing popup menu
            // PopupMenuButton<String>(
            //   onSelected: (value) {
            //     if (value == 'update') {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => UpdateCategoryPage(category: category),
            //         ),
            //       );
            //     } else if (value == 'delete') {
            //       DeleteCategory().confirmDelete(context, category.id);
            //     }
            //   },
            //   itemBuilder: (context) => const [
            //     PopupMenuItem(value: 'update', child: Text('Update')),
            //     PopupMenuItem(value: 'delete', child: Text('Delete')),
            //   ],
            // ),
            IconButton(
                onPressed: () {
                  updatedialog(category);
                  print("cccccUUUUpppdatee");
                },
                icon: Icon(Icons.more_vert))
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }
}
