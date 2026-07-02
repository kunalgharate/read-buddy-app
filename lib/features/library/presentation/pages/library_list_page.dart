import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../bloc/library_bloc.dart';
import '../../domain/entities/library_entity.dart';

class LibraryListPage extends StatelessWidget {
  const LibraryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryBloc>()..add(const LoadLibraries()),
      child: const _LibraryListView(),
    );
  }
}

class _LibraryListView extends StatelessWidget {
  const _LibraryListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libraries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            tooltip: 'Librarians',
            onPressed: () => Navigator.pushNamed(context, '/assign-librarian'),
          ),
        ],
      ),
      body: BlocConsumer<LibraryBloc, LibraryState>(
        listener: (context, state) {
          if (state is LibraryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Library deleted')),
            );
            context.read<LibraryBloc>().add(const LoadLibraries());
          }
          if (state is LibraryUpdated) {
            context.read<LibraryBloc>().add(const LoadLibraries());
          }
        },
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibraryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LibraryBloc>()
                        .add(const LoadLibraries()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is LibrariesLoaded) {
            if (state.libraries.isEmpty) {
              return const Center(
                child: Text('No libraries yet. Tap + to add one.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LibraryBloc>().add(const LoadLibraries());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.libraries.length,
                itemBuilder: (context, index) =>
                    _LibraryCard(library: state.libraries[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/library/create');
          if (result == true && context.mounted) {
            context.read<LibraryBloc>().add(const LoadLibraries());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Library'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final LibraryEntity library;
  const _LibraryCard({required this.library});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/library/detail',
            arguments: library,
          );
          if (result == true && context.mounted) {
            context.read<LibraryBloc>().add(const LoadLibraries());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  library.isSuperLibrary ? Icons.star : Icons.local_library,
                  color: library.isSuperLibrary
                      ? Colors.amber
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            library.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (library.isSuperLibrary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'SUPER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      library.address.fullAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (library.openHours.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        library.openHours,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'toggle_super') {
                    context
                        .read<LibraryBloc>()
                        .add(ToggleSuperLibraryEvent(library.id));
                  } else if (value == 'delete') {
                    _confirmDelete(context, library);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle_super',
                    child: Text(library.isSuperLibrary
                        ? 'Remove Super'
                        : 'Make Super'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LibraryEntity library) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Library'),
        content: Text('Delete "${library.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LibraryBloc>().add(DeleteLibraryEvent(library.id));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
