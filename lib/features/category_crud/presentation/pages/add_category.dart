import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/widgets/category_form_widget.dart';

class AddCategory extends StatelessWidget {
  const AddCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Category",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052E44),
          ),
        ),
      ),
      body: CategoryFormWidget(
        onSubmit: (String title, Item? category, File? image) {
          if (image == null) return;
          context.read<CategoryBloc>().add(AddCategoryEvent(
                title: title,
                description: '',
                parentCategoryId: category?.id,
                image: image,
              ));
        },
      ),
    );
  }
}
