import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile_bloc.dart';

/// Example widget showing how to use the optimized ProfileBloc for single field updates
class ProfileFieldUpdateExample extends StatefulWidget {
  const ProfileFieldUpdateExample({super.key});

  @override
  State<ProfileFieldUpdateExample> createState() => _ProfileFieldUpdateExampleState();
}

class _ProfileFieldUpdateExampleState extends State<ProfileFieldUpdateExample> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Update Example')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFieldUpdated) {
            // Show success message for single field update
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.updatedField.toUpperCase()} updated to: ${state.newValue}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            // Pre-fill controllers with current user data
            _nameController.text = state.user.name;
            _emailController.text = state.user.email;
            _phoneController.text = state.user.phno ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Name Field
                  _buildProfileField(
                    label: 'Name',
                    controller: _nameController,
                    fieldKey: 'name',
                    currentValue: state.user.name,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildProfileField(
                    label: 'Email',
                    controller: _emailController,
                    fieldKey: 'email',
                    currentValue: state.user.email,
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  _buildProfileField(
                    label: 'Phone',
                    controller: _phoneController,
                    fieldKey: 'mobile',
                    currentValue: state.user.phno ?? '',
                  ),
                  const SizedBox(height: 32),

                  // Load Profile Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfileEvent());
                    },
                    child: const Text('Reload Profile'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('No profile data available'),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required String fieldKey,
    required String currentValue,
  }) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              enabled: !isUpdating,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: const OutlineInputBorder(),
                suffixIcon: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () => _updateField(fieldKey, controller.text),
                      ),
              ),
              onFieldSubmitted: (value) => _updateField(fieldKey, value),
            ),
          ],
        );
      },
    );
  }

  void _updateField(String fieldKey, String value) {
    if (value.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Field cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Trigger single field update
    context.read<ProfileBloc>().add(
      UpdateProfileFieldEvent(
        field: fieldKey,
        value: value.trim(),
      ),
    );
  }
}

/// Usage in your app:
/// 
/// BlocProvider(
///   create: (context) => getIt<ProfileBloc>()..add(LoadProfileEvent()),
///   child: const ProfileFieldUpdateExample(),
/// )
