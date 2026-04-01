// lib/features/questionaries/presentation/screens/questions_screens.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/question_entity.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';

class QuestionaryScreen extends StatelessWidget {
  const QuestionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuestionBloc>()..add(LoadQuestions()),
      child: const _QuestionaryScreenContent(),
    );
  }
}

class _QuestionaryScreenContent extends StatefulWidget {
  const _QuestionaryScreenContent();

  @override
  State<_QuestionaryScreenContent> createState() =>
      _QuestionaryScreenContentState();
}

class _QuestionaryScreenContentState extends State<_QuestionaryScreenContent> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                  setState(() => currentIndex--);
                },
              )
            : null,
        title: const Text(
          'Onboarding',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state is QuestionSubmitted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Submitted Answers'),
                content: SingleChildScrollView(
                  child: Text(state.jsonResult),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuestionLoaded) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: state.questions.length,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => currentIndex = index),
                    itemBuilder: (_, index) {
                      final question = state.questions[index];
                      final selectedAnswers = state.answers[question.id] ?? [];
                      return _QuestionPage(
                        question: question,
                        selectedAnswers: selectedAnswers,
                        onAnswerSelected: (option) {
                          context
                              .read<QuestionBloc>()
                              .add(SelectAnswer(question.id, option));
                        },
                      );
                    },
                  ),
                ),
                _buildIndicators(state.questions.length),
                const SizedBox(height: 20),
                _buildNavigationButtons(context, state),
                const SizedBox(height: 24),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) => _buildDot(index)),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            currentIndex == index ? const Color(0xFF2CE07F) : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuestionLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: currentIndex == state.questions.length - 1
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CE07F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () =>
                    context.read<QuestionBloc>().add(SubmitAnswers()),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    setState(() => currentIndex++);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CE07F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Next',
                      style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final QuestionEntity question;
  final List<String> selectedAnswers;
  final Function(String) onAnswerSelected;

  const _QuestionPage({
    required this.question,
    required this.selectedAnswers,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${question.id}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ...question.options.map((option) {
            final isSelected = selectedAnswers.contains(option);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onAnswerSelected(option),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2CE07F).withValues(alpha: 0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2CE07F)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        question.type == QuestionType.single
                            ? (isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked)
                            : (isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank),
                        color:
                            isSelected ? const Color(0xFF2CE07F) : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.black87 : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
