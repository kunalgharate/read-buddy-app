import 'package:flutter/material.dart';

class EditGenderScreen extends StatefulWidget {
  final String currentGender;

  const EditGenderScreen({
    super.key,
    required this.currentGender,
  });

  @override
  State<EditGenderScreen> createState() => _EditGenderScreenState();
}

class _EditGenderScreenState extends State<EditGenderScreen> {
  late String selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.currentGender;
  }

  void _saveGender() {
    Navigator.pop(context, selectedGender);
  }

  void _cancel() {
    Navigator.pop(context);
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
          onPressed: _cancel,
        ),
        title: const Text(
          'Gender',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Gender Selection
            const Text(
              'Select your gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Male Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Male';
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedGender == 'Male'
                        ? Colors.blue
                        : Colors.grey.shade300,
                    width: selectedGender == 'Male' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedGender == 'Male'
                      ? Colors.blue.shade50
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.male,
                      color: selectedGender == 'Male'
                          ? Colors.blue
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Male',
                      style: TextStyle(
                        color: selectedGender == 'Male'
                            ? Colors.blue
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (selectedGender == 'Male')
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            
            // Female Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Female';
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedGender == 'Female'
                        ? Colors.pink
                        : Colors.grey.shade300,
                    width: selectedGender == 'Female' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedGender == 'Female'
                      ? Colors.pink.shade50
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.female,
                      color: selectedGender == 'Female'
                          ? Colors.pink
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Female',
                      style: TextStyle(
                        color: selectedGender == 'Female'
                            ? Colors.pink
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (selectedGender == 'Female')
                      const Icon(
                        Icons.check_circle,
                        color: Colors.pink,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            
            // Others Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedGender = 'Others';
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedGender == 'Others'
                        ? Colors.purple
                        : Colors.grey.shade300,
                    width: selectedGender == 'Others' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: selectedGender == 'Others'
                      ? Colors.purple.shade50
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.transgender,
                      color: selectedGender == 'Others'
                          ? Colors.purple
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Others',
                      style: TextStyle(
                        color: selectedGender == 'Others'
                            ? Colors.purple
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (selectedGender == 'Others')
                      const Icon(
                        Icons.check_circle,
                        color: Colors.purple,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
           
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGender,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}