import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/library_inventory_entity.dart';
import '../bloc/library_inventory_bloc.dart';

/// Shows all books in a specific library's inventory.
/// Admin can edit quantity or remove books from here.
class LibraryBooksPage extends StatelessWidget {
  final String libraryId;
  final String libraryName;

  const LibraryBooksPage({
    super.key,
    required this.libraryId,
    required this.libraryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryInventoryBloc>()
        ..add(LoadLibraryInventory(libraryId: libraryId)),
      child: _LibraryBooksView(
        libraryId: libraryId,
        libraryName: libraryName,
      ),
    );
  }
}

class _LibraryBooksView extends StatelessWidget {
  final String libraryId;
  final String libraryName;

  const _LibraryBooksView({
    required this.libraryId,
    required this.libraryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Books in $libraryName')),
      body: BlocConsumer<LibraryInventoryBloc, LibraryInventoryState>(
        listener: (context, state) {
          if (state is InventoryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book removed from library')),
            );
          }
          if (state is LibraryInventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LibraryInventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibraryInventoryLoaded) {
            if (state.inventory.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_books_outlined,
                        size: 48, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No books added to this library yet.',
                        style: TextStyle(color: AppColors.textSecondary)),
                    Text('Use "Add Book" on the library detail page.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<LibraryInventoryBloc>()
                    .add(LoadLibraryInventory(libraryId: libraryId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.inventory.length,
                itemBuilder: (context, index) => _InventoryCard(
                  item: state.inventory[index],
                  libraryId: libraryId,
                ),
              ),
            );
          }
          if (state is LibraryInventoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LibraryInventoryBloc>()
                        .add(LoadLibraryInventory(libraryId: libraryId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final LibraryInventoryEntity item;
  final String libraryId;

  const _InventoryCard({required this.item, required this.libraryId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.bookCoverUrl != null && item.bookCoverUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.bookCoverUrl!,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.bookTitle ?? 'Unknown Book',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.bookAuthor ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _chip(item.formatType, AppColors.primary),
                      const SizedBox(width: 6),
                      if (item.variantLanguage != null)
                        _chip(item.variantLanguage!, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${item.totalCopies}  •  Available: ${item.availableCopies}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: item.availableCopies > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Update Copies',
                  onPressed: () => _showUpdateDialog(context),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  tooltip: 'Remove',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    final controller =
        TextEditingController(text: item.totalCopies.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Copies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.bookTitle ?? 'Book',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${item.borrowedCount} copies currently borrowed/locked',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Copies',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newCount = int.tryParse(controller.text);
              if (newCount == null || newCount < 0) return;
              Navigator.pop(ctx);
              context.read<LibraryInventoryBloc>().add(
                    UpdateInventoryEvent(
                      id: item.id,
                      totalCopies: newCount,
                      libraryId: libraryId,
                    ),
                  );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    if (item.borrowedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot remove — ${item.borrowedCount} copies are currently borrowed or locked.',
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Book'),
        content: Text(
          'Remove "${item.bookTitle ?? 'this book'}" from the library?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LibraryInventoryBloc>().add(
                    DeleteInventoryEvent(
                      id: item.id,
                      libraryId: libraryId,
                    ),
                  );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
