import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';

/// Blocks a route/widget unless the signed-in user passes [canAccess].
///
/// The role is read from the app-wide [ProfileBloc] (provided above
/// `MaterialApp`, so every route can resolve it). If the profile has not
/// loaded yet — e.g. a cold deep link — it falls back to the cached user in
/// secure storage so a legitimate manager is never blocked by that race.
///
/// The gate fails closed: nothing gated is built while the role is still
/// unknown, and unknown/empty roles are treated as "not permitted".
class RoleGuard extends StatefulWidget {
  final bool Function(String? role) canAccess;
  final Widget child;
  final String? deniedMessage;

  const RoleGuard({
    super.key,
    required this.canAccess,
    required this.child,
    this.deniedMessage,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  String? _cachedRole;
  bool _cachedRoleResolved = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _cachedRole = profileState.user.role;
      _cachedRoleResolved = true;
    } else {
      _resolveCachedRole();
    }
  }

  Future<void> _resolveCachedRole() async {
    String? role;
    try {
      role = (await getIt<SecureStorageUtil>().getUser())?.role;
    } catch (_) {
      role = null;
    }
    if (!mounted) return;
    setState(() {
      _cachedRole = role;
      _cachedRoleResolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return _gate(profileState.user.role);
    }
    if (_cachedRoleResolved) {
      return _gate(_cachedRole);
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _gate(String? role) {
    if (widget.canAccess(role)) return widget.child;
    return AccessDeniedScreen(message: widget.deniedMessage);
  }
}

/// Shown in place of a guarded route when the signed-in user lacks permission.
class AccessDeniedScreen extends StatelessWidget {
  final String? message;

  const AccessDeniedScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'You don\'t have permission to access this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ??
                    'This area is restricted to administrators and managers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryColor(context),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) navigator.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
