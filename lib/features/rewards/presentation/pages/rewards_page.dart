import 'package:flutter/material.dart';
import '../widgets/my_rewards_card.dart';
import '../widgets/reading_streak_card.dart';
import '../widgets/badges_section.dart';
import '../widgets/challenges_section.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Rewards',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF052E44),
          ),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('My Rewards'),
            SizedBox(height: 10),
            MyRewardsCard(),
            SizedBox(height: 16),
            ReadingStreakCard(),
            SizedBox(height: 24),
            BadgesSection(),
            SizedBox(height: 24),
            ChallengesSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: Color(0xFF052E44),
      ),
    );
  }
}
