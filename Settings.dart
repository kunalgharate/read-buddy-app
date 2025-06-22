import 'package:flutter/material.dart';
import 'Wishlist.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.grey[350],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(21.0),
              color: Colors.grey[350],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kunal Tripathi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Reduced top padding to bring fields closer to profile
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Workflow',
                    onTap: () {
                      // Add navigation for Admin Workflow if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.favorite_border,
                    label: 'My Wishlist',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    onTap: () {
                      // Add navigation for Address if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    label: 'My Request',
                    onTap: () {
                      // Add navigation for My Request if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.download_outlined,
                    label: 'Downloads',
                    onTap: () {
                      // Add navigation for Downloads if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.card_giftcard_outlined,
                    label: 'Rewards',
                    onTap: () {
                      // Add navigation for Rewards if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.notifications_none_outlined,
                    label: 'Notification',
                    onTap: () {
                      // Add navigation for Notification if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.feedback_outlined,
                    label: 'Feedback',
                    onTap: () {
                      // Add navigation for Feedback if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      // Add navigation for Privacy Policy if needed
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      _showCustomLogoutDialog(context);
                    },
                  ),
                  // Added extra space at bottom
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon, 
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Message
                  const Text(
                    'Do you really want to log out\n from ReadBuddy?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button (Green)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add your logout logic here
                        // For example: Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cancel Button (White with border)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}