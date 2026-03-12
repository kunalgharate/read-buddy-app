// presentation/cubit/onboarding_state.dart
import '../../domain/entities/onboarding_question_entity.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingQuestionEntity> questions;
  final Map<int, List<String>> answers;
  final int currentIndex;

  OnboardingLoaded({
    required this.questions,
    required this.answers,
    this.currentIndex = 0,
  });

  OnboardingLoaded copyWith({Map<int, List<String>>? answers, int? currentIndex}) {
    return OnboardingLoaded(
      questions: questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class OnboardingComplete extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;
  OnboardingError(this.message);
}