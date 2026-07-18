import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _searchQuery = '';
  String _roleFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final dio = getIt<Dio>();
      final params = <String, dynamic>{'limit': 50};
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
      if (_roleFilter != 'all') params['role'] = _roleFilter;

      final response = await dio.get(
        ApiConstants.adminUsers,
        queryParameters: params,
      );
      final data = response.data;
      final list = data['users'] ?? data['data'] ?? data;
      setState(() {
        _users = list is List ? List<Map<String, dynamic>>.from(list) : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  Future<void> _blockUser(String userId) async {
    await _patchAction(userId, 'block', 'User blocked');
  }

  Future<void> _unblockUser(String userId) async {
    await _patchAction(userId, 'unblock', 'User unblocked');
  }

  Future<void> _makePrime(String userId) async {
    final duration = await _showDurationPicker();
    if (duration == null) return;
    try {
      final dio = getIt<Dio>();
      await dio.patch(
        '${ApiConstants.adminUsers}/$userId/make-prime',
        data: {'durationDays': duration},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prime granted for $duration days')),
        );
      }
      _fetchUsers();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _removePrime(String userId) async {
    await _patchAction(userId, 'remove-prime', 'Prime removed');
  }

  Future<void> _makeLibrarian(String userId) async {
    // Step 1: Make librarian
    try {
      final dio = getIt<Dio>();
      await dio.patch('${ApiConstants.adminUsers}/$userId/make-librarian');
    } catch (e) {
      _showError(e);
      return;
    }

    // Step 2: Show library picker
    if (!mounted) return;
    final libraryId = await _showLibraryPicker();
    if (libraryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User made librarian (no library assigned)')),
        );
      }
      _fetchUsers();
      return;
    }

    // Step 3: Assign library
    try {
      final dio = getIt<Dio>();
      await dio.patch(
        '${ApiConstants.adminUsers}/$userId/assign-library',
        data: {'libraryId': libraryId},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Librarian assigned to library')),
        );
      }
      _fetchUsers();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _removeLibrarian(String userId) async {
    await _patchAction(userId, 'unassign-library', 'Librarian removed');
  }

  void _confirmRemoveAdmin(String userId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text(
          'Are you sure you want to remove admin privileges from "$name"? '
          'This user will be demoted to a regular user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeAdmin(userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAdmin(String userId) async {
    await _patchAction(userId, 'remove-admin', 'Admin privileges removed');
  }

  Future<void> _patchAction(
      String userId, String action, String message) async {
    try {
      final dio = getIt<Dio>();
      await dio.patch('${ApiConstants.adminUsers}/$userId/$action');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      _fetchUsers();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<int?> _showDurationPicker() {
    return showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Prime Duration'),
        children: [
          _durationOption(ctx, 30, '30 Days'),
          _durationOption(ctx, 90, '90 Days'),
          _durationOption(ctx, 180, '6 Months'),
          _durationOption(ctx, 365, '1 Year'),
          _durationOption(ctx, 0, 'Permanent'),
        ],
      ),
    );
  }

  Widget _durationOption(BuildContext ctx, int days, String label) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(ctx, days),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<String?> _showLibraryPicker() async {
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(ApiConstants.libraries);
      final data = response.data;
      final libraries = List<Map<String, dynamic>>.from(
        data['libraries'] ?? [],
      );

      if (!mounted) return null;
      if (libraries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No libraries available')),
        );
        return null;
      }

      return showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Assign to Library'),
          children: libraries.map((lib) {
            final name = lib['name'] ?? 'Unknown';
            final city = lib['address']?['city'] ?? '';
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, lib['_id']),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.local_library,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          if (city.isNotEmpty)
                            Text(city,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    } catch (e) {
      _showError(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _searchQuery = '';
                          _fetchUsers();
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) {
                _searchQuery = v;
                _fetchUsers();
              },
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'user', 'librarian', 'admin'].map((role) {
                  final selected = _roleFilter == role;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(role == 'all' ? 'All' : role.toUpperCase()),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _roleFilter = role);
                        _fetchUsers();
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // User list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _users.length,
                          itemBuilder: (context, index) =>
                              _buildUserCard(_users[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final id = user['_id'] ?? '';
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final role = user['userRole'] ?? 'user';
    final isPrime = user['isPrime'] ?? false;
    final isBlocked = user['isBlocked'] ?? false;
    final isVerified = user['isEmailVerified'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isBlocked
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isBlocked ? Colors.red : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPrime) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                          ],
                          if (isBlocked) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.block,
                                color: Colors.red, size: 14),
                          ],
                        ],
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _roleColor(role),
                    ),
                  ),
                ),
              ],
            ),
            if (!isVerified)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('Email not verified',
                        style: TextStyle(fontSize: 11, color: Colors.orange)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            // Action buttons — contextual based on state
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Block / Unblock
                if (isBlocked)
                  _actionChip(
                    label: 'Unblock',
                    icon: Icons.lock_open,
                    color: AppColors.primary,
                    onTap: () => _unblockUser(id),
                  )
                else
                  _actionChip(
                    label: 'Block',
                    icon: Icons.block,
                    color: Colors.red,
                    onTap: () => _blockUser(id),
                  ),

                // Prime
                if (isPrime)
                  _actionChip(
                    label: 'Remove Prime',
                    icon: Icons.star_border,
                    color: Colors.orange,
                    onTap: () => _removePrime(id),
                  )
                else
                  _actionChip(
                    label: 'Grant Prime',
                    icon: Icons.star,
                    color: Colors.amber,
                    onTap: () => _makePrime(id),
                  ),

                // Role actions
                if (role == 'user')
                  _actionChip(
                    label: 'Make Librarian',
                    icon: Icons.local_library,
                    color: Colors.blue,
                    onTap: () => _makeLibrarian(id),
                  ),
                if (role == 'librarian')
                  _actionChip(
                    label: 'Remove Librarian',
                    icon: Icons.person_remove,
                    color: Colors.deepOrange,
                    onTap: () => _removeLibrarian(id),
                  ),
                if (role == 'admin')
                  _actionChip(
                    label: 'Remove Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    color: Colors.red,
                    onTap: () => _confirmRemoveAdmin(id, name),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'librarian':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}
