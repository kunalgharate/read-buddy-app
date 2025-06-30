import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_event.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeletecrudBook {
  void confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: const Text(
          "Are you sure you want to permanently delete this book from the ReadBuddy app?",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.black))),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              TextButton(
                onPressed: () {
                  context.read<BookCrudBloc>().add(DeleteBookCrudEvent(id));
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.black))),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
