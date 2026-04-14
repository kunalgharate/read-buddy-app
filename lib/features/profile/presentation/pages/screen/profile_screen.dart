import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/services/app_preferences.dart';
import '../../../../../core/utils/secure_storage_utils.dart';
import '../../../../home/presentation/screens/home_screen.dart';
import '../../../domain/entities/avatar_user_model.dart';
import '../../../domain/entities/user_profile.dart';
import '../../blocs/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(LoadProfileEvent()), // ← fixed
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  static const _navy = Color(0xFF1E3A5F);
  static const _green = Color(0xFF00C853);
  static const _grey = Color(0xFF666666);

  void _showAvatarSheet(BuildContext context, ProfileUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _AvatarBottomSheet(
        user: user,
        onSelected: (avatarName) {
          context
              .read<ProfileBloc>()
              .add(UpdateAvatarEvent(avatarName)); // ← fixed
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.logout, color: Color(0xFF00C853), size: 22),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF1E3A5F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await getIt<SecureStorageUtil>().clearAll();
              await AppPreferences.clear();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/signin', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
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

  Widget _buildAvatarCircle(ProfileUser user, bool isUpdating) {
    final avatarAsset = AppAvatars.assetFor(user.userAvatar);

    Widget content;
    if (isUpdating) {
      content = Container(
        color: const Color(0xFFE8F5E9),
        child: const Center(
          child: CircularProgressIndicator(color: _green, strokeWidth: 2),
        ),
      );
    } else if (avatarAsset != null) {
      content = Image.asset(
        avatarAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(user.name),
      );
    } else if (user.picture != null && user.picture!.isNotEmpty) {
      content = Image.network(
        user.picture!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(user.name),
      );
    } else {
      content = _avatarFallback(user.name);
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _green, width: 2),
      ),
      child: ClipOval(child: content),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: _green,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
      BuildContext context, ProfileUser user, bool isUpdating) {
    return Column(
      children: [
        _buildAvatarCircle(user, isUpdating),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isUpdating ? null : () => _showAvatarSheet(context, user),
          icon: const Icon(Icons.face, color: _green, size: 18),
          label: const Text(
            'Change Avatar',
            style: TextStyle(color: _green, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: const BorderSide(color: _green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
          SizedBox(width: 4),
          Text(
            'Prime Member',
            style: TextStyle(
              color: Color(0xFFB8860B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildInfoSection(ProfileUser user) {
    return _buildSection(
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
    );
  }

  Widget _buildAccountSection(ProfileUser user) {
    return _buildSection(
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
        _buildDivider(),
        _buildTile(
          icon: Icons.emoji_events_outlined,
          label: 'Badges',
          value: user.badges.isEmpty
              ? 'No badges yet'
              : '${user.badges.length} badge(s)',
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
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
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: _grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: _grey)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<ProfileBloc>().add(LoadProfileEvent()), // ← fixed
            child: const Text('Retry', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileUser user, bool isUpdating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAvatarSection(context, user, isUpdating),
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
          const SizedBox(height: 8),
          if (user.isPrime) _buildPrimeBadge(),
          const SizedBox(height: 32),
          _buildInfoSection(user),
          const SizedBox(height: 24),
          _buildAccountSection(user),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _navy),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.settings_outlined, color: Color(0xFF1565C0)),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is AvatarUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar updated successfully!'),
                backgroundColor: _green,
              ),
            );
          } else if (state is ProfileError) {
            // ← fixed: was ProfileFailure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message), // ← fixed: was state.errorMessage
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }
          if (state is ProfileError) {
            // ← fixed: was ProfileFailure
            return _buildErrorState(
                context, state.message); // ← fixed: was state.errorMessage
          }

          ProfileUser? user;
          bool isUpdating = false;

          if (state is ProfileLoaded) user = state.user;
          if (state is ProfileUpdating) {
            user = state.user;
            isUpdating = true;
          }
          if (state is AvatarUpdateSuccess) user = state.user;

          if (user == null) return const SizedBox.shrink();
          return _buildBody(context, user, isUpdating);
        },
      ),
    );
  }
}

class _AvatarBottomSheet extends StatelessWidget {
  final ProfileUser user;
  final void Function(String avatarName) onSelected;

  const _AvatarBottomSheet({
    required this.user,
    required this.onSelected,
  });

  static const _navy = Color(0xFF1E3A5F);
  static const _green = Color(0xFF00C853);
  static const _grey = Color(0xFF666666);

  bool _isSelected(AvatarOption avatar) =>
      user.userAvatar?.toLowerCase() == avatar.name.toLowerCase();

  Widget _buildAvatarItem(BuildContext context, AvatarOption avatar) {
    final selected = _isSelected(avatar);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSelected(avatar.name);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _green : const Color(0xFFE0E0E0),
                width: 2.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _green.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                avatar.assetPath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFE8F5E9),
                  child: Center(
                    child: Text(
                      avatar.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            avatar.name,
            style: TextStyle(
              fontSize: 11,
              color: selected ? _green : _grey,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Your Avatar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select an avatar that represents you',
            style: TextStyle(fontSize: 13, color: _grey),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 20,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: AppAvatars.all.length,
            itemBuilder: (context, index) =>
                _buildAvatarItem(context, AppAvatars.all[index]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
