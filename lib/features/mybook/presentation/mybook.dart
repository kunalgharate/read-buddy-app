import 'package:flutter/material.dart';

class Mybook extends StatefulWidget {
  const Mybook({super.key});

  @override
  State<Mybook> createState() => _MybookState();
}

class _MybookState extends State<Mybook> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Mybooks_collection"),
      ),
    );
  }
}
