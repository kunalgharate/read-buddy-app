import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/item_entity.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/widgets/category_form_widget.dart';

class UpdateCategoryPage extends StatelessWidget {
  final CategoryEntity category;

  const UpdateCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Update Category",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052E44),
          ),
        ),
      ),
      body: CategoryFormWidget(
        initialTitle: category.title,
        initialImageUrl: category.imageUrl,
        initialCategory: category.parentCategory.isNotEmpty
            ? Item(id: category.id, name: category.parentCategory)
            : null,
        onSubmit: (String title, Item? selectedCategory, File? image) {
          context.read<CategoryBloc>().add(UpdateCategoryEvent(
                id: category.id,
                title: title,
                description: '',
                parentCategoryId: selectedCategory?.id,
                image: image,
              ));
        },
      ),
    );
  }
}
