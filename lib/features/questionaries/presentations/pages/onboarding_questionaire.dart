// presentation/screens/onboarding_questionnaire.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../../core/services/app_preferences.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/entity/onboarding_question_entity.dart';
import '../bloc/on_boarding_bloc.dart';
import '../bloc/on_boarding_event.dart';
import '../bloc/on_boarding_state.dart';
import '../widgets/question_card.dart';

class OnboardingQuestionnaire extends StatelessWidget {
  const OnboardingQuestionnaire({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingBloc>()..add(FetchQuestionsEvent()),
      child: const _OnboardingQuestionnaireView(),
    );
  }
}

class _OnboardingQuestionnaireView extends StatelessWidget {
  const _OnboardingQuestionnaireView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) async {
        if (state is OnboardingCompleted) {
          // Update saved user so splash never shows questionnaire again
          final secureStorage = getIt<SecureStorageUtil>();
          final user = await secureStorage.getUser();
          if (user != null) {
            await secureStorage.saveUser(
              _copyUserWithOnboarding(user),
            );
          }
          await AppPreferences.setLoggedIn(true);

          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OnboardingLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OnboardingError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(FetchQuestionsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OnboardingQuestionsLoaded) {
          return _buildQuestionnaire(context, state);
        }

        if (state is OnboardingSubmitting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2CE07F)),
                  SizedBox(height: 16),
                  Text('Saving your preferences...'),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildQuestionnaire(
    BuildContext context,
    OnboardingQuestionsLoaded state,
  ) {
    final question = state.currentQuestion;
    final selectedAnswers = state.answers[question.id] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Skip & Progress
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF5B6675),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF2CE07F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${state.currentIndex + 1}/${state.questions.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Question
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2939),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                question.quesType == QuestionType.singleSelection
                    ? 'Select one option'
                    : 'Select all that apply',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 32),

              // Answer options
              Expanded(
                child: ListView.separated(
                  itemCount: question.answers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final answer = question.answers[index];
                    final isSelected = selectedAnswers.contains(answer);

                    return QuestionCard(
                      answer: answer,
                      isSelected: isSelected,
                      onTap: () => context.read<OnboardingBloc>().add(
                            SelectAnswerEvent(
                              question: question,
                              answer: answer,
                            ),
                          ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Navigation buttons
              Row(
                children: [
                  if (!state.isFirstQuestion)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context
                            .read<OnboardingBloc>()
                            .add(PreviousQuestionEvent()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF2CE07F)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Color(0xFF2CE07F)),
                        ),
                      ),
                    ),
                  if (!state.isFirstQuestion) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: selectedAnswers.isEmpty
                          ? null
                          : () {
                              if (state.isLastQuestion) {
                                context
                                    .read<OnboardingBloc>()
                                    .add(SubmitPreferencesEvent());
                              } else {
                                context
                                    .read<OnboardingBloc>()
                                    .add(NextQuestionEvent());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2CE07F),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        state.isLastQuestion ? 'Submit' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Copy user with onboardingCompleted = true
  dynamic _copyUserWithOnboarding(dynamic user) {
    return AppUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      role: user.role,
      isPrime: user.isPrime,
      finesDue: user.finesDue,
      isEmailVerified: user.isEmailVerified,
      onboardingCompleted: true, // ← updated
      badges: user.badges,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      version: user.version,
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      picture: user.picture,
      phno: user.phno,
      gender: user.gender,
      wishlist: user.wishlist,
    );
  }
}
