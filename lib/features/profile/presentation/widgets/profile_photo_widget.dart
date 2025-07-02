import 'package:flutter/material.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const ProfilePhotoWidget({
    super.key,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3182CE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton.icon(
            onPressed: onTap,
            icon: const Icon(
              Icons.camera_alt,
              size: 16,
              color: Color(0xFF3182CE),
            ),
            label: const Text(
              'Change Photo',
              style: TextStyle(
                color: Color(0xFF3182CE),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
