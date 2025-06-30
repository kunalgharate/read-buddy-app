import 'package:flutter/material.dart';

import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:read_buddy_app/features/bookcrud/presentation/pages/deletecrud_book.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/widgets/updatebook_stepper.dart';

class BooksCollection extends StatelessWidget {
  final BookCrudEntity bookcollection;
  const BooksCollection({super.key, required this.bookcollection});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: Colors.white,
        shape: const BeveledRectangleBorder(
          side: BorderSide(
            color: Colors.black, // ✅ Border color
            width: 1 / 2, // ✅ Border width
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: bookcollection.coverImageUrl,
              height: 100,
              width: 100,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 8),
            Expanded(
              // ✅ Wrap the Column with Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    bookcollection.title,
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
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text(
                            "Motivation",
                            style: TextStyle(
                                color: Color.fromARGB(255, 6, 86, 150)),
                          )),
                      SizedBox(
                        width: 5,
                      ),
                      TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text(
                            "E-Book",
                            style: TextStyle(
                                color: Color.fromARGB(255, 6, 86, 150)),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  updatedialog(context, bookcollection);
                },
                icon: const Icon(
                  Icons.more_vert,
                  size: 25,
                  color: Colors.black,
                ))
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
    shape: RoundedRectangleBorder(
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
                Navigator.pushReplacement(
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
