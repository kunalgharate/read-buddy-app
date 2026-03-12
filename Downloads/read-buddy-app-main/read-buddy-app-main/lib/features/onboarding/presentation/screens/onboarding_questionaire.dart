import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user_preference/presentation/widgets/option_tile.dart';
import '../../data/remotesource/onboarding_local_data_source.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/use_cases/get_onboarding_data.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class OnboardingQuestionScreen extends StatelessWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(
        GetOnboardingQuestionsUseCase(
          OnboardingRepositoryImpl(OnboardingLocalDataSource()),
        ),
      )..loadQuestions(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  static const Color primaryGreen = Color(0xFF3DDC84);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingComplete) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      },
      builder: (context, state) {
        if (state is OnboardingLoading || state is OnboardingInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is OnboardingError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        if (state is OnboardingLoaded) {
          final q = state.questions[state.currentIndex];
          final isMulti = q.type == 'multi_select';
          final isLast = state.currentIndex == state.questions.length - 1;
          final progress = (state.currentIndex + 1) / state.questions.length;
          final bottomPadding = MediaQuery.of(context).padding.bottom;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (state.currentIndex > 0)
                              GestureDetector(
                                onTap: () => context.read<OnboardingCubit>().previous(),
                                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                              )
                            else
                              const SizedBox(width: 18),
                            if (!isLast)
                              GestureDetector(
                                onTap: () => Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (route) => false),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          'Question ${state.currentIndex + 1} of ${state.questions.length}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          q.question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        if (isMulti) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Select all that apply',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ...List.generate(q.options.length, (index) {
                          final option = q.options[index];
                          final isSelected = state.answers[q.id]?.contains(option) ?? false;
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < q.options.length - 1 ? 10 : 0),
                            child: _OptionTile(
                              option: option,
                              isSelected: isSelected,
                              isMulti: isMulti,
                              onTap: () => context.read<OnboardingCubit>().toggleAnswer(q.id, option, isMulti),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding > 0 ? bottomPadding : 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.read<OnboardingCubit>().next(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isLast ? 'Continue' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isMulti,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xFF3DDC84);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: isMulti
                  ? BoxDecoration(
                color: isSelected ? primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade400,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(5),
              )
                  : BoxDecoration(
                color: isSelected ? primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade400,
                  width: 1.8,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(
                isMulti ? Icons.check : Icons.circle,
                size: isMulti ? 14 : 10,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}