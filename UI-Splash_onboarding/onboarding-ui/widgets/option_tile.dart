import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionTile extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? Colors.green : Colors.transparent;
    final bgColor = Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            iconPath.endsWith('.svg')
                ? SvgPicture.asset(iconPath, height: 22, width: 22)
                : Image.asset(iconPath, height: 22, width: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedOption = '';

  void selectOption(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Option Tile Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OptionTile(
              label: 'Home',
              iconPath: 'assets/icons/home.svg',
              isSelected: selectedOption == 'Home',
              onTap: () => selectOption('Home'),
            ),
            OptionTile(
              label: 'Profile',
              iconPath: 'assets/icons/profile.svg',
              isSelected: selectedOption == 'Profile',
              onTap: () => selectOption('Profile'),
            ),
            OptionTile(
              label: 'Settings',
              iconPath: 'assets/icons/settings.svg',
              isSelected: selectedOption == 'Settings',
              onTap: () => selectOption('Settings'),
            ),
            // Correct usage as per the suggestion
            OptionTile(
              label: 'Pages',
              iconPath: 'assets/icons/pages.svg',
              isSelected: selectedOption == 'Pages',
              onTap: () => selectOption('Pages'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    ),
  );
}
