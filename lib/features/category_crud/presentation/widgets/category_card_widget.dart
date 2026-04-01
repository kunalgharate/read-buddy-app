import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/delete_category.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/update_category.dart';

// Card widget representing a single category item in the list
class CategoryCardWidget extends StatelessWidget {
  final CategoryEntity category;

  const CategoryCardWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Outer card container with border and white background
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF262626)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      // Horizontal layout: image | content | menu
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category cover image
          Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: category.imageUrl,
                height: 96.36,
                width: 81,
                fit: BoxFit.cover,
                // Loading placeholder while image fetches
                placeholder: (context, url) => const SizedBox(
                  width: 81,
                  height: 96.36,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                // Fallback icon when image fails to load
                errorWidget: (context, url, error) => const SizedBox(
                  width: 81,
                  height: 96.36,
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          // Content area: title, parent category chip, stock status chip
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category title
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141414),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action chips row: parent category label and stock status
                  Wrap(
                    spacing: 4,
                    children: [
                      _ActionChip(
                        label: category.parentCategory.isNotEmpty
                            ? category.parentCategory
                            : 'Root Category',
                        color: category.parentCategory.isNotEmpty
                            ? const Color(0xFF2CE07F)
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 3-dot popup menu for edit and delete actions
          _MoreMenu(category: category),
        ],
      ),
    );
  }
}

// Small colored label chip used for tags like parent category and stock status
class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    // Pill-shaped container with background color
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      // Chip label text
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF052E44),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final CategoryEntity category;

  const _MoreMenu({required this.category});

  @override
  Widget build(BuildContext context) {
    // Popup menu triggered by the vertical dots icon
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) {
        // Navigate to update page when edit is selected
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateCategoryPage(category: category),
            ),
          );
        // Show delete confirmation dialog when delete is selected
        } else if (value == 'delete') {
          DeleteCategory().confirmDelete(context, category.id);
        }
      },
      itemBuilder: (_) => const [
        // Edit option
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        // Delete option
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}
