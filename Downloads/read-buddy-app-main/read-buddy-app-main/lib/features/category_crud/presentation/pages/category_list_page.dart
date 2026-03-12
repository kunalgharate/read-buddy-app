import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/utils/image_helper.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/add_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/delete_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/update_category.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  TextEditingController searchCategoryController = TextEditingController();

  @override
  void dispose() {
    searchCategoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    context.read<CategoryBloc>().add(LoadCategories());
    super.initState();
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
            const SizedBox(
              height: 20,
            ),
            Container(
              //width: MediaQuery.sizeOf(context).width * 0.85,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: TextField(
                cursorColor: Colors.grey,
                controller: searchCategoryController,
                onChanged: (value) {
                  setState(() {
                    searchCategoryController.text = value;
                    print("Searching categories: $value");
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Search Categories',
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    )),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoryLoaded) {
                    if (state.categories.isEmpty) {
                      return const Center(child: Text("No categories found."));
                    }
                    final searchText =
                        searchCategoryController.text.toLowerCase();
                    final filteredCategories =
                        state.categories.where((category) {
                      return category.title.toLowerCase().contains(searchText);
                    }).toList();
                    return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredCategories.isNotEmpty
                          ? filteredCategories.length
                          : state.categories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories.isNotEmpty
                            ? filteredCategories[index]
                            : state.categories[index];
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
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: const Color.fromARGB(255, 96, 177, 228),
        shape: CircleBorder(),
        tooltip: 'Add Book',
        onPressed: () {
          // Your action
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddCategory()));
        },
        child: const Center(
          child: Text(
            'Add Category',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UpdateCategoryPage(category: category),
                          ));
                    },
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text("Delete Category"),
                    onTap: () {
                      Navigator.pop(context);
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
    return Container(
      padding: const EdgeInsets.all(8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  height: 120,
                  width: 100,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 2,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text(
                            category.parentCategory,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 6, 86, 150),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: const Text(
                            "In Stock",
                            style: TextStyle(
                              color: Color.fromARGB(255, 6, 86, 150),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      updatedialog(category);
                    },
                    icon: const Icon(
                      Icons.more_vert,
                      size: 25,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
