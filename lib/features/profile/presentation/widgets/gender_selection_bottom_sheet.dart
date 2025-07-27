import 'package:flutter/material.dart';

class GenderSelectionBottomSheet extends StatefulWidget {
  final String? currentGender;
  final Function(String) onGenderSelected;

  const GenderSelectionBottomSheet({
    super.key,
    this.currentGender,
    required this.onGenderSelected,
  });

  @override
  State<GenderSelectionBottomSheet> createState() => _GenderSelectionBottomSheetState();
}

class _GenderSelectionBottomSheetState extends State<GenderSelectionBottomSheet> {
  String? _selectedGender;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _genderOptions = [
    {
      'value': 'male',
      'label': 'Male',
      'icon': Icons.male,
    },
    {
      'value': 'female',
      'label': 'Female',
      'icon': Icons.female,
    },
    {
      'value': 'other',
      'label': 'Other',
      'icon': Icons.transgender,
    },
    {
      'value': 'rather not to say',
      'label': 'Rather not to say',
      'icon': Icons.help_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.currentGender?.toLowerCase();
  }

  void _handleGenderSelection(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _saveGender() async {
    if (_selectedGender == null) return;
    
    // If no change, just close
    if (_selectedGender?.toLowerCase() == widget.currentGender?.toLowerCase()) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));
      
      widget.onGenderSelected(_selectedGender!);
      Navigator.pop(context);
      
    } catch (error) {
      // Handle error if needed
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF3182CE),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select Gender',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3182CE),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _selectedGender != null ? _saveGender : null,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _selectedGender != null 
                            ? const Color(0xFF3182CE) 
                            : Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Gender options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _genderOptions.length,
              itemBuilder: (context, index) {
                final option = _genderOptions[index];
                final isSelected = _selectedGender == option['value'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : () => _handleGenderSelection(option['value']),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF3182CE) 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected 
                              ? const Color(0xFF3182CE).withOpacity(0.05)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              option['icon'],
                              color: isSelected 
                                  ? const Color(0xFF3182CE) 
                                  : Colors.grey.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option['label'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.w500,
                                  color: isSelected 
                                      ? const Color(0xFF3182CE) 
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF3182CE),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
