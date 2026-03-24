// presentation/bloc/onboarding_state.dart

import '../../domain/entity/onboarding_question_entity.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}
class OnboardingLoading extends OnboardingState {}

class OnboardingQuestionsLoaded extends OnboardingState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  // questionId → selected answer(s)
  final Map<String, List<String>> answers;

  OnboardingQuestionsLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answers,
  });

  QuestionEntity get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex == questions.length - 1;
  bool get isFirstQuestion => currentIndex == 0;
  double get progress =>
      questions.isEmpty ? 0.0 : (currentIndex + 1) / questions.length;

  OnboardingQuestionsLoaded copyWith({
    int? currentIndex,
    Map<String, List<String>>? answers,
  }) {
    return OnboardingQuestionsLoaded(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
    );
  }
}

class OnboardingSubmitting extends OnboardingState {}
class OnboardingCompleted extends OnboardingState {}
class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}