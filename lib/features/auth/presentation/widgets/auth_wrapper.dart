import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../permissions/presentation/widgets/permission_guard.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  final String userRole;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.userRole,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _shouldShowPermissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionStatus();
    });
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsGranted = prefs.getBool('permissions_granted_${widget.userRole}') ?? false;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShowPermissions = !permissionsGranted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShowPermissions = true;
        });
      }
    }
  }

  Future<void> _onPermissionsGranted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissions_granted_${widget.userRole}', true);
      
      if (mounted) {
        setState(() {
          _shouldShowPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error saving permission state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3182CE),
          ),
        ),
      );
    }

    if (_shouldShowPermissions) {
      return PermissionGuard(
        child: widget.child,
        onPermissionsGranted: _onPermissionsGranted,
      );
    }

    return widget.child;
  }
}
