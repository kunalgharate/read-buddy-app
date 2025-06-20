import 'package:flutter/material.dart';

import '../widgets/option_tile.dart';


class QuestionFiveScreen extends StatefulWidget {
  const QuestionFiveScreen({super.key});

  @override
  State<QuestionFiveScreen> createState() => _QuestionFiveScreenState();
}

class _QuestionFiveScreenState extends State<QuestionFiveScreen> {
  String? selectedOption;
  final int currentPage = 5;
  final int totalPages = 5;

  final options = [
    {'label': 'Less than 10 pages', 'icon': 'assets/pages.svg'},
    {'label': '10 – 20 pages', 'icon': 'assets/pages.svg'},
    {'label': '20 – 40 pages', 'icon': 'assets/pages.svg'},
    {'label': 'More than 40 pages', 'icon': 'assets/pages.svg'},
  ];

  void selectOption(String label) {
    setState(() {
      selectedOption = label;
    });
  }

  void handleSubmit() {
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one option")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank You!"),
        content: Text("Your selections:\n\n${selectedOption!}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Go to first screen
            },
            child: const Text("Continue"),
          ),
        ],
      ),
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
                    "Question 5",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "How many pages do you usually read in a day?",
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
                          backgroundColor: const Color(0xFF2CE07F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: handleSubmit,
                        child: const Text(
                          "Continue",
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
