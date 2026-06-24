import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/deletecrud_book.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/updatebook_stepper.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';

class BooksCollection extends StatelessWidget {
  final BookCrudEntity bookcollection;
  const BooksCollection({super.key, required this.bookcollection});

  /// Resolves category to display name.
  /// Backend now returns populated category objects, so this usually works directly.
  /// Falls back to CategoryBloc lookup if only an ID is available.
  String _resolveCategoryName(BuildContext context) {
    final categoryValue = bookcollection.category;
    final categoryId = bookcollection.categoryId;

    // If category is already a readable name (not a MongoDB ObjectId), show it
    if (categoryValue.isNotEmpty) {
      final isObjectId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(categoryValue);
      if (!isObjectId) return categoryValue;
    }

    // Fallback: resolve from CategoryBloc using the ID
    final idToLookup = (categoryId != null && categoryId.isNotEmpty)
        ? categoryId
        : categoryValue;
    if (idToLookup.isEmpty) return '';

    final categoryState = context.watch<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      final match = categoryState.categories.where(
        (cat) => cat.id == idToLookup,
      );
      if (match.isNotEmpty) return match.first.title;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Colors.black,
          width: 1 / 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 8,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: bookcollection.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: bookcollection.coverImageUrl,
                      height: 120,
                      width: 100,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      width: 100,
                      color: const Color(0xFF042153),
                      child: const Icon(Icons.menu_book_rounded,
                          size: 32, color: Colors.white30),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookcollection.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bookcollection.author,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            updatedialog(context, bookcollection);
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            size: 24,
                            color: Colors.black,
                          ))
                    ],
                  ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: Text(
                            _resolveCategoryName(context),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 6, 86, 150)),
                          )),
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: Text(
                            bookcollection.format,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 6, 86, 150)),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/book-variants',
                              arguments:
                                  BookCrudModel.fromEntity(bookcollection),
                            );
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F0FF),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.translate,
                                  size: 14, color: Color(0xFF1565C0)),
                              SizedBox(width: 4),
                              Text(
                                "Variants",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void updatedialog(BuildContext context, BookCrudEntity book) async {
  print("update Dialog messaging");
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 Important: makes it wrap content
          children: [
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text("Update Book"),
              onTap: () {
                Navigator.pop(context);
                print("Your book id is ${book.id}");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UpdateBookStepper(
                              book_id: book.id ?? "",
                            )));
                // Optional: close bottom sheet
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text("Manage Variants"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/book-variants',
                  arguments: BookCrudModel.fromEntity(book),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Book"),
              onTap: () {
                Navigator.pop(context);
                DeletecrudBook().confirmDelete(context, book.id ?? "");
              },
            ),
          ],
        ),
      );
    },
  );
}
