import 'package:flutter/material.dart';
import '../../../../core/utils/selection_store.dart';
import '../widgets/option_tile.dart';
import 'question_two_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final List<Map<String, String>> options = [
    {"label": "Fiction", "icon": "assets/icons/fiction.png"},
    {"label": "Non Fiction", "icon": "assets/non_fiction.png"},
    {"label": "Fantasy", "icon": "assets/icons/fantasy.png"},
    {
      "label": "Business & Productivity",
      "icon": "assets/business_productivity.png",
    },
    {"label": "Biographies", "icon": "assets/biographies.png"},
    {"label": "Mystery & Thriller", "icon": "assets/mystery_thriller.png"},
    {"label": "Self Help", "icon": "assets/self_help.png"},
  ];

  final Set<String> selectedOptions = {};

  void toggleSelection(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
        SelectionStore.removeAnswer(option);
      } else {
        selectedOptions.add(option);
        SelectionStore.addAnswer(option);
      }
    });
  }

  void goToNext() {
    if (selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one option")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuestionTwoScreen()),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: LinearProgressIndicator(
                    value: 0.2,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                    minHeight: 10,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Question 1",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    "What type of books do you enjoy\nreading the most?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: options.map((option) {
                      return OptionTile(
                        label: option['label']!,
                        iconPath: option['icon']!,
                        isSelected: selectedOptions.contains(option['label']),
                        onTap: () => toggleSelection(option['label']!),
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
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: goToNext,
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
    );
  }
}
