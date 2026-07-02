import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/library_entity.dart';

/// Page to view a library's details and manage its assigned librarians.
/// Allows searching users and assigning multiple librarians.
class LibraryDetailPage extends StatefulWidget {
  final LibraryEntity library;
  const LibraryDetailPage({super.key, required this.library});

  @override
  State<LibraryDetailPage> createState() => _LibraryDetailPageState();
}

class _LibraryDetailPageState extends State<LibraryDetailPage> {
  List<Map<String, dynamic>> _librarians = [];
  bool _loadingLibrarians = true;

  @override
  void initState() {
    super.initState();
    _fetchLibrarians();
  }

  Future<void> _fetchLibrarians() async {
    setState(() => _loadingLibrarians = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        '${ApiConstants.adminLibrariesPath}/${widget.library.id}/librarians',
      );
      final data = response.data;
      setState(() {
        _librarians =
            List<Map<String, dynamic>>.from(data['librarians'] ?? []);
        _loadingLibrarians = false;
      });
    } catch (e) {
      setState(() => _loadingLibrarians = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load librarians: $e')),
        );
      }
    }
  }

  Future<void> _assignLibrarian(String userId, String userName) async {
    try {
      final dio = getIt<Dio>();
      await dio.patch(
        '${ApiConstants.adminUsers}/$userId/assign-library',
        data: {'libraryId': widget.library.id},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName assigned as librarian')),
        );
      }
      _fetchLibrarians();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign: $e')),
        );
      }
    }
  }

  Future<void> _unassignLibrarian(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Librarian'),
        content: Text('Remove "$userName" from this library?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final dio = getIt<Dio>();
      await dio.patch('${ApiConstants.adminUsers}/$userId/unassign-library');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName removed')),
        );
      }
      _fetchLibrarians();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }

  void _showSearchAndAssign() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UserSearchSheet(
        onUserSelected: (user) {
          Navigator.pop(context);
          _assignLibrarian(
            user['_id'] ?? user['id'] ?? '',
            user['name'] ?? 'User',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lib = widget.library;
    return Scaffold(
      appBar: AppBar(
        title: Text(lib.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Library',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/library/create',
                arguments: lib,
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Library info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        lib.isSuperLibrary
                            ? Icons.star
                            : Icons.local_library,
                        color: lib.isSuperLibrary
                            ? Colors.amber
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lib.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (lib.isSuperLibrary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined, lib.address.fullAddress),
                  if (lib.contactNumber.isNotEmpty)
                    _infoRow(Icons.phone_outlined, lib.contactNumber),
                  if (lib.openHours.isNotEmpty)
                    _infoRow(Icons.access_time, lib.openHours),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Librarians section
            Row(
              children: [
                const Text(
                  'Assigned Librarians',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showSearchAndAssign,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loadingLibrarians)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (_librarians.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.people_outline, size: 40, color: AppColors.textHint),
                    SizedBox(height: 8),
                    Text(
                      'No librarians assigned yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Tap "Add" to search and assign users',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              )
            else
              ...(_librarians.map((lib) => _LibrarianTile(
                    name: lib['name'] ?? '',
                    email: lib['email'] ?? '',
                    onRemove: () => _unassignLibrarian(
                      lib['_id'] ?? '',
                      lib['name'] ?? '',
                    ),
                  ))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSearchAndAssign,
        icon: const Icon(Icons.person_add),
        label: const Text('Assign Librarian'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibrarianTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onRemove;

  const _LibrarianTile({
    required this.name,
    required this.email,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(email,
            style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove, color: Colors.red, size: 20),
          tooltip: 'Remove',
          onPressed: onRemove,
        ),
      ),
    );
  }
}

/// Bottom sheet with user search for assigning librarians.
class _UserSearchSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> user) onUserSelected;
  const _UserSearchSheet({required this.onUserSelected});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiConstants.adminUsers,
        queryParameters: {'search': query.trim(), 'limit': 20},
      );
      final data = response.data;
      final users = data['users'] ?? data['data'] ?? data;
      setState(() {
        _results = users is List
            ? List<Map<String, dynamic>>.from(users)
            : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Search User to Assign',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  final name = user['name'] ?? '';
                  final email = user['email'] ?? '';
                  final role = user['userRole'] ?? user['role'] ?? 'user';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text('$email • $role',
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(
                        Icons.add_circle_outline, color: AppColors.primary),
                    onTap: () => widget.onUserSelected(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
