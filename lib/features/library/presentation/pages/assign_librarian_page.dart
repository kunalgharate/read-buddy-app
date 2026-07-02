import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../bloc/library_bloc.dart';

/// Admin page to view, assign, and unassign librarians.
/// If [libraryId] is provided, shows librarians for that library only.
class AssignLibrarianPage extends StatelessWidget {
  final String? libraryId;
  const AssignLibrarianPage({super.key, this.libraryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryBloc>()..add(LoadLibrariansEvent()),
      child: _AssignLibrarianView(libraryId: libraryId),
    );
  }
}

class _AssignLibrarianView extends StatelessWidget {
  final String? libraryId;
  const _AssignLibrarianView({this.libraryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Librarians')),
      body: BlocConsumer<LibraryBloc, LibraryState>(
        listener: (context, state) {
          if (state is LibrarianAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Librarian assigned')),
            );
            context.read<LibraryBloc>().add(LoadLibrariansEvent());
          }
          if (state is LibrarianUnassigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Librarian removed')),
            );
            context.read<LibraryBloc>().add(LoadLibrariansEvent());
          }
          if (state is LibraryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibrariansLoaded) {
            final librarians = state.librarians;
            if (librarians.isEmpty) {
              return const Center(
                child: Text('No librarians assigned yet.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: librarians.length,
              itemBuilder: (context, index) {
                final lib = librarians[index];
                final name = lib['name'] ?? '';
                final email = lib['email'] ?? '';
                final assignedLibrary = lib['assignedLibrary'];
                final libraryName = assignedLibrary is Map
                    ? assignedLibrary['name'] ?? 'Unknown'
                    : 'Not assigned';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email,
                            style: const TextStyle(fontSize: 12)),
                        Text(
                          '📚 $libraryName',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove,
                          color: Colors.red, size: 20),
                      tooltip: 'Unassign',
                      onPressed: () => _confirmUnassign(
                        context,
                        lib['_id'] ?? '',
                        name,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Assign'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _confirmUnassign(BuildContext context, String userId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Librarian'),
        content: Text('Remove "$name" from their library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LibraryBloc>().add(UnassignLibrarianEvent(userId));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    final userIdCtrl = TextEditingController();
    final libraryIdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Librarian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter user ID and library ID to assign.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userIdCtrl,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: libraryIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Library ID',
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
              final userId = userIdCtrl.text.trim();
              final libId = libraryIdCtrl.text.trim();
              if (userId.isEmpty || libId.isEmpty) return;
              Navigator.pop(ctx);
              context
                  .read<LibraryBloc>()
                  .add(AssignLibrarianEvent(userId, libId));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
