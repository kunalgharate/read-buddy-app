import 'package:flutter/material.dart';
import '../widgets/option_tile.dart';
import 'question_three_screen.dart';

class QuestionTwoScreen extends StatefulWidget {
  const QuestionTwoScreen({super.key});

  @override
  State<QuestionTwoScreen> createState() => _QuestionTwoScreenState();
}

class _QuestionTwoScreenState extends State<QuestionTwoScreen> {
  String? selectedOption;
  final int currentPage = 2;
  final int totalPages = 5;

  final options = [
    {'label': 'Fiction', 'icon': 'assets/icons/fiction.png'},
    {'label': 'Non-fiction', 'icon': 'assets/non_fiction.png'},
    {'label': 'Self-help', 'icon': 'assets/icons/self_help.png'},
    {'label': 'Biographies', 'icon': 'assets/icons/biographies.png'},
    {'label': 'Fantasy', 'icon': 'assets/icons/fantasy.png'},
  ];

  void selectOption(String label) {
    setState(() {
      selectedOption = label;
    });
  }

  void goToNext() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one option")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuestionThreeScreen()),
    );
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
                    "Question 2",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What genre do you mostly prefer?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      children: options.map((option) {
                        return OptionTile(
                          label: option['label']!,
                          iconPath: option['icon']!,
                          isSelected: selectedOption == option['label'],
                          onTap: () => selectOption(option['label']!),
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
                        onPressed: goToNext,
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
