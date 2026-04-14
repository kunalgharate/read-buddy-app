import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/widgets/category_form_widget.dart';

class UpdateCategoryPage extends StatelessWidget {
  final CategoryEntity category;

  const UpdateCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return CategoryFormWidget(existing: category);
  }
}
