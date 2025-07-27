
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/ui_utils.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../../profile/presentation/pages/edit_screens/edit_email_screen.dart';
import '../../../profile/presentation/pages/edit_screens/edit_mobile_screen.dart';
import '../../../profile/presentation/pages/edit_screens/edit_name_screen.dart';
import '../../../profile/presentation/widgets/profile_field_widget.dart';
import '../../../profile/presentation/widgets/profile_photo_widget.dart';
import '../../../profile/presentation/widgets/permission_helper.dart';
import '../../../profile/presentation/widgets/gender_selection_bottom_sheet.dart';
import '../../../settings/settings_screen.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const ProfileTab({super.key, this.onBackPressed});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    // Add the event after the widget is built to avoid the "bad state" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(LoadProfileEvent());
      }
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  SettingsScreen()),
    );
  }

  void _openEditName(String currentName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameScreen(currentName: currentName),
      ),
    );

    if (result != null && result != currentName && mounted) {
      context.read<ProfileBloc>().add(UpdateProfileFieldEvent(field: 'name', value: result));
    }
  }

  void _openEditMobile(String currentMobile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMobileScreen(currentMobile: currentMobile),
      ),
    );

    if (result != null && result != currentMobile && mounted) {
      context.read<ProfileBloc>().add(UpdateProfileFieldEvent(field: 'mobile', value: result));
    }
  }

  void _showEmailLockedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Email Locked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Email address cannot be changed as it\'s your primary account identifier. If you need to update your email, please contact support.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3182CE),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEditEmail(String currentEmail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmailScreen(currentEmail: currentEmail),
      ),
    );

    if (result != null && result != currentEmail && mounted) {
      context.read<ProfileBloc>().add(UpdateProfileFieldEvent(field: 'email', value: result));
    }
  }

  void _openEditGender(String currentGender) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GenderSelectionBottomSheet(
          currentGender: currentGender.isEmpty || currentGender == 'Not set' 
              ? null 
              : currentGender,
          onGenderSelected: (String selectedGender) {
            if (mounted) {
              context.read<ProfileBloc>().add(
                UpdateProfileFieldEvent(
                  field: 'gender', 
                  value: selectedGender,
                ),
              );
            }
          },
        );
      },
    );
  }

  void _handlePermissionError(String errorMessage) {
    String permissionType = 'gallery';
    if (errorMessage.toLowerCase().contains('camera')) {
      permissionType = 'camera';
    }
    
    PermissionHelper.showPermissionDialogIfNeeded(
      context,
      permissionType: permissionType,
      onPermissionGranted: () {
        // Retry the photo selection after permission is granted
        final source = permissionType == 'camera' ? PhotoSource.camera : PhotoSource.gallery;
        _handlePhotoSelection(source);
      },
    );
  }

  void _handlePhotoSelection(PhotoSource source) {
    if (!mounted) return;
    
    // Try to update profile photo
    context.read<ProfileBloc>().add(UpdateProfilePhotoEvent(source: source));
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 25),

                _buildPhotoOptionItem(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _handlePhotoSelection(PhotoSource.camera);
                  },
                ),

                const SizedBox(height: 15),

                _buildPhotoOptionItem(
                  icon: Icons.photo_library_outlined,
                  title: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _handlePhotoSelection(PhotoSource.gallery);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                icon,
                color: Colors.black87,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: _openSettings,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF3182CE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            // Check if it's a permission error
            if (state.message.toLowerCase().contains('permission denied')) {
              _handlePermissionError(state.message);
            } else {
              UiUtils.showErrorSnackBar(
                context,
                message: state.message,
              );
            }
          } else if (state is ProfileUpdated) {
            UiUtils.showSuccessSnackBar(
              context,
              message: 'Profile updated successfully',
            );
          }
        },
        builder: (context, state) {
          // Handle loading state
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3182CE),
              ),
            );
          }

          // Handle updating state - show current data with loading indicator
          if (state is ProfileUpdating) {
            return Stack(
              children: [
                _buildProfileContent(state.user),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3182CE),
                    ),
                  ),
                ),
              ],
            );
          }

          // Handle error state
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.read<ProfileBloc>().add(LoadProfileEvent());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3182CE),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle loaded/updated states
          final user = (state is ProfileLoaded) 
              ? state.user 
              : (state is ProfileUpdated) 
                  ? state.user 
                  : null;

          if (user == null) {
            return const Center(child: Text('No user data available'));
          }

          return _buildProfileContent(user);
        },
      ),
    );
  }

  Widget _buildProfileContent(AppUser user) {
    if (kDebugMode) {
      print('🎨 ProfileTab: Building UI with user data:');
      print('👤 UI User Name: "${user.name}"');
      print('👤 UI User Email: "${user.email}"');
      print('👤 UI User Phone: "${user.phno}"');
      print('👤 UI User Gender: "${user.gender}"');
      print('👤 UI User Picture: "${user.picture}"');
      print('✅ UI User Email Verified: ${user.isEmailVerified}');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),



          // Profile Photo
          ProfilePhotoWidget(
            imageUrl: user.picture,
            onTap: _showPhotoOptions,
          ),

          const SizedBox(height: 30),

          // Profile Fields
          ProfileFieldWidget(
            icon: Icons.person_outline,
            label: 'Name',
            value: user.name.isNotEmpty ? user.name : 'Not set',
            onTap: () => _openEditName(user.name),
          ),

          const SizedBox(height: 20),

          ProfileFieldWidget(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: user.phno?.isNotEmpty == true ? user.phno! : 'Not set',
            onTap: () => _openEditMobile(user.phno ?? ''),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: _showEmailLockedMessage,
            child: ProfileFieldWidget(
              icon: Icons.email_outlined,
              label: 'Email Id',
              value: user.email.isNotEmpty ? user.email : 'Not set',
              onTap: () {}, // Empty callback since we handle tap with GestureDetector
              isEditable: false, // Lock the email field
            ),
          ),

          const SizedBox(height: 20),

          ProfileFieldWidget(
            icon: _getGenderIcon(user.gender ?? 'Not set'),
            label: 'Gender',
            value: _formatGenderDisplay(user.gender),
            onTap: () => _openEditGender(user.gender ?? ''),
          ),

          const SizedBox(height: 20),

          // Account Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: user.isEmailVerified
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user.isEmailVerified
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  user.isEmailVerified
                      ? Icons.verified_user
                      : Icons.warning_outlined,
                  color: user.isEmailVerified
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isEmailVerified
                            ? 'Account Verified'
                            : 'Email Not Verified',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: user.isEmailVerified
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      if (!user.isEmailVerified)
                        Text(
                          'Please verify your email address',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatGenderDisplay(String? gender) {
    if (gender == null || gender.isEmpty) {
      return 'Not set';
    }
    
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      case 'rather not to say':
        return 'Rather not to say';
      default:
        return gender; // Return as-is if not recognized
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      case 'other':
        return Icons.transgender;
      case 'rather not to say':
        return Icons.help_outline;
      default:
        return Icons.person_outline;
    }
  }
}
