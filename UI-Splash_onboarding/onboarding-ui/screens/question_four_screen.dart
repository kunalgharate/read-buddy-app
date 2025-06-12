import 'package:flutter/material.dart';
import '../widgets/option_tile.dart';
import 'question_five_screen.dart';

class QuestionFourScreen extends StatefulWidget {
  const QuestionFourScreen({super.key});

  @override
  State<QuestionFourScreen> createState() => _QuestionFourScreenState();
}

class _QuestionFourScreenState extends State<QuestionFourScreen> {
  final int currentPage = 4;
  final int totalPages = 5;
  final List<String> selectedOptions = [];

  final options = [
    {'label': 'Morning', 'icon': 'assets/morning.svg'},
    {'label': 'Afternoon', 'icon': 'assets/afternoon.svg'},
    {'label': 'Night', 'icon': 'assets/night.svg'},
    {'label': 'During commutes', 'icon': 'assets/during_commutes.svg'},
    {'label': 'Before bed', 'icon': 'assets/before_bed.svg'},
  ];

  void toggleOption(String label) {
    setState(() {
      if (selectedOptions.contains(label)) {
        selectedOptions.remove(label);
      } else if (selectedOptions.length < 2) {
        selectedOptions.add(label);
      } else {
        // Optional: show warning if user tries to select more than 2
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can select up to 2 options only.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: currentPage / totalPages,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Question 4",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "When do you usually read?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: options.map((option) {
                        final label = option['label']!;
                        return OptionTile(
                          label: label,
                          iconPath: option['icon']!,
                          isSelected: selectedOptions.contains(label),
                          onTap: () => toggleOption(label),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuestionFiveScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
