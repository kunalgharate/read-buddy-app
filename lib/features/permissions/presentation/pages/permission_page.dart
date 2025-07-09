import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permission_service.dart';
import '../bloc/permission_bloc.dart';
import '../widgets/permission_item_widget.dart';

class PermissionPage extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final bool showSkipButton;

  const PermissionPage({
    super.key,
    this.onPermissionsGranted,
    this.showSkipButton = false,
  });

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPermissions();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadPermissions() {
    context.read<PermissionBloc>().add(LoadPermissionsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<PermissionBloc, PermissionState>(
          listener: (context, state) {
            if (state is PermissionAllGranted) {
              widget.onPermissionsGranted?.call();
            }
          },
          builder: (context, state) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildPermissionsList(state),
                      SizedBox(height: 10,),
                      _buildActionButtons(state),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3182CE), Color(0xFF63B3ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'App Permissions',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We need these permissions to provide you with the best experience',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsList(PermissionState state) {
    if (state is PermissionLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3182CE),
          ),
        ),
      );
    }

    if (state is PermissionError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading permissions',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3182CE),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final permissions = (state is PermissionLoaded) 
        ? state.permissions 
        : (state is PermissionUpdated) 
            ? state.permissions
            : (state is PermissionAllGranted)
                ? state.permissions
                : <PermissionInfo>[];

    return Expanded(
      child: ListView.builder(
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          final permission = permissions[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            curve: Curves.easeOutCubic,
            child: PermissionItemWidget(
              permission: permission,
              onTap: () => _requestPermission(permission.permission),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(PermissionState state) {
    final isLoading = state is PermissionLoading;
    final permissions = (state is PermissionLoaded) 
        ? state.permissions 
        : (state is PermissionUpdated) 
            ? state.permissions
            : (state is PermissionAllGranted)
                ? state.permissions
                : <PermissionInfo>[];

    final allRequiredGranted = permissions
        .where((p) => p.isRequired)
        .every((p) => p.isGranted);

    return Column(
      children: [
        // Grant All Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _requestAllPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: allRequiredGranted 
                  ? Colors.green.shade600 
                  : const Color(0xFF3182CE),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        allRequiredGranted 
                            ? Icons.check_circle 
                            : Icons.security,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        allRequiredGranted 
                            ? 'All Permissions Granted' 
                            : 'Grant All Permissions',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Continue Button (only show if all required permissions are granted)
        if (allRequiredGranted) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => widget.onPermissionsGranted?.call(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Continue to App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Skip Button (optional)
        if (widget.showSkipButton) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => widget.onPermissionsGranted?.call(),
            child: Text(
              'Skip for now',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _requestPermission(AppPermission permission) {
    context.read<PermissionBloc>().add(
      RequestPermissionEvent(permission),
    );
  }

  void _requestAllPermissions() {
    context.read<PermissionBloc>().add(
      RequestAllPermissionsEvent(),
    );
  }
}
