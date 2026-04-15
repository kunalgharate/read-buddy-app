import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/services/app_preferences.dart';
import '../../../../../core/utils/secure_storage_utils.dart';
import '../../../../../features/auth/domain/entities/app_user.dart';
import '../../blocs/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(LoadProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  static const _navy = Color(0xFF1E3A5F);
  static const _green = Color(0xFF00C853);
  static const _grey = Color(0xFF666666);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.logout, color: _green, size: 22),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(foregroundColor: _grey),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await getIt<SecureStorageUtil>().clearAll();
                await AppPreferences.clear();
              } catch (_) {
                // Navigate regardless of clearing errors
              } finally {
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/signin', (_) => false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: _grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: _grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? _navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 16, color: Color(0xFFF0F0F0));

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppUser user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _green, width: 2),
              color: const Color(0xFFE8F5E9),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 14, color: _grey),
          ),
          const SizedBox(height: 32),
          _buildSection(
            title: 'Personal Information',
            children: [
              _buildTile(
                icon: Icons.person_outline,
                label: 'Full Name',
                value: user.name,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phno?.isNotEmpty == true ? user.phno! : 'Not set',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Account',
            children: [
              _buildTile(
                icon: Icons.account_circle_outlined,
                label: 'Role',
                value: user.role,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.attach_money,
                label: 'Fines Due',
                value: user.finesDue == 0 ? 'None' : 'Rs. ${user.finesDue}',
                valueColor: user.finesDue > 0 ? Colors.red : _green,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.verified_outlined,
                label: 'Email Verified',
                value: user.isEmailVerified ? 'Yes' : 'No',
                valueColor: user.isEmailVerified ? _green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: _grey),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: _grey),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(LoadProfileEvent()),
                    child:
                        const Text('Retry', style: TextStyle(color: _green)),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileLoaded) {
            return _buildBody(context, state.user);
          }
          if (state is ProfileUpdating) {
            return _buildBody(context, state.user);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
