import 'package:flutter/material.dart';
import 'settings.dart';
import 'Edit_name_screen.dart';
import 'Edit_mobile_screen.dart';
import 'Edit_email_screen.dart'; 
import 'Edit_gender_screen.dart'; 

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  
  String userName = 'mayankgupta'; // Default name
  String userMobile = '8585858585'; // Default mobile number
  String userEmail = 'mayank@gmail.com'; // Default email
  String selectedGender = 'Male'; // Default gender

  @override
  void dispose() {
    super.dispose();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _openEditName() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNameScreen(currentName: userName),
      ),
    );
    
    if (result != null) {
      setState(() {
        userName = result;
      });
    }
  }

  void _openEditMobile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMobileScreen(currentMobile: userMobile),
      ),
    );
    
    if (result != null) {
      setState(() {
        userMobile = result;
      });
    }
  }

  void _openEditEmail() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmailScreen(currentEmail: userEmail),
      ),
    );
    
    if (result != null) {
      setState(() {
        userEmail = result;
      });
    }
  }

  void _openEditGender() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGenderScreen(currentGender: selectedGender),
      ),
    );
    
    if (result != null) {
      setState(() {
        selectedGender = result;
      });
    }
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera functionality will be implemented')),
                    );
                  },
                ),
                
                const SizedBox(height: 15),
                
             
                _buildPhotoOptionItem(
                  icon: Icons.photo_library_outlined,
                  title: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gallery functionality will be implemented')),
                    );
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

  
  Widget _buildNameField() {
    return GestureDetector(
      onTap: _openEditName,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, 
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildMobileField() {
    return GestureDetector(
      onTap: _openEditMobile,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone_outlined,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, 
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userMobile,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return GestureDetector(
      onTap: _openEditEmail,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.email_outlined,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Id',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, 
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildGenderField() {
    return GestureDetector(
      onTap: _openEditGender,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              selectedGender == 'Male' 
                  ? Icons.male
                  : selectedGender == 'Female'
                      ? Icons.female
                      : Icons.transgender,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, 
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedGender,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context),
        ),
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
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton.icon(
                  onPressed: _showPhotoOptions,
                  icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                  label: const Text(
                    'Change Photo',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              _buildNameField(),
              
              const SizedBox(height: 20),
            
              _buildMobileField(),
              
              const SizedBox(height: 20),
              
              _buildEmailField(),
    
              const SizedBox(height: 20),
              
              _buildGenderField(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}