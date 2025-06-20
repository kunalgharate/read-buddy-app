import 'package:flutter/material.dart';
import '../widgets/option_tile.dart';
import 'question_four_screen.dart';

class QuestionThreeScreen extends StatefulWidget {
  const QuestionThreeScreen({super.key});

  @override
  State<QuestionThreeScreen> createState() => _QuestionThreeScreenState();
}

class _QuestionThreeScreenState extends State<QuestionThreeScreen> {
  final int currentPage = 3;
  final int totalPages = 5;
  final List<String> selectedOptions = [];

  final options = [
    {'label': 'E-books', 'icon': 'assets/ebooks.svg'},
    {'label': 'Physical books', 'icon': 'assets/physical_books.svg'},
    {'label': 'Audiobooks', 'icon': 'assets/audiobooks.svg'},
    {'label': 'A mix of all three', 'icon': 'assets/a_mix_of_all_three.svg'},
  ];

  void toggleOption(String label) {
    setState(() {
      if (selectedOptions.contains(label)) {
        selectedOptions.remove(label);
      } else {
        selectedOptions.add(label);
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
                    "Question 3",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "What is your preferred reading format?",
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
                              builder: (context) => const QuestionFourScreen(),
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
