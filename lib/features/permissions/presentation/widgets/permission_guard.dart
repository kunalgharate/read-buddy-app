import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/permission_service.dart';
import '../bloc/permission_bloc.dart';
import '../pages/permission_page.dart';

class PermissionGuard extends StatelessWidget {
  final Widget child;
  final bool checkOnInit;
  final VoidCallback? onPermissionsGranted;

  const PermissionGuard({
    super.key,
    required this.child,
    this.checkOnInit = true,
    this.onPermissionsGranted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PermissionBloc>(),
      child: PermissionGuardContent(
        child: child,
        checkOnInit: checkOnInit,
        onPermissionsGranted: onPermissionsGranted,
      ),
    );
  }
}

class PermissionGuardContent extends StatefulWidget {
  final Widget child;
  final bool checkOnInit;
  final VoidCallback? onPermissionsGranted;

  const PermissionGuardContent({
    super.key,
    required this.child,
    required this.checkOnInit,
    this.onPermissionsGranted,
  });

  @override
  State<PermissionGuardContent> createState() => _PermissionGuardContentState();
}

class _PermissionGuardContentState extends State<PermissionGuardContent> {
  bool _permissionsChecked = false;
  bool _allPermissionsGranted = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkOnInit) {
      _checkPermissions();
    } else {
      _permissionsChecked = true;
      _allPermissionsGranted = true;
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final permissionService = getIt<PermissionService>();
      final allGranted = await permissionService.areAllRequiredPermissionsGranted();
      
      setState(() {
        _permissionsChecked = true;
        _allPermissionsGranted = allGranted;
      });
    } catch (e) {
      setState(() {
        _permissionsChecked = true;
        _allPermissionsGranted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3182CE),
          ),
        ),
      );
    }

    if (!_allPermissionsGranted) {
      return PermissionPage(
        onPermissionsGranted: () {
          setState(() {
            _allPermissionsGranted = true;
          });
          widget.onPermissionsGranted?.call();
        },
        showSkipButton: false,
      );
    }

    return widget.child;
  }
}

// Helper function to show permission page manually
void showPermissionPage(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => getIt<PermissionBloc>(),
        child: PermissionPage(
          onPermissionsGranted: () {
            Navigator.of(context).pop();
          },
          showSkipButton: true,
        ),
      ),
    ),
  );
}
