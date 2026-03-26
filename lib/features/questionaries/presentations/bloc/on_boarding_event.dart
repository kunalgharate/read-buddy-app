// presentation/bloc/onboarding_event.dart

import '../../domain/entity/onboarding_question_entity.dart';

abstract class OnboardingEvent {}

class FetchQuestionsEvent extends OnboardingEvent {}

class SelectAnswerEvent extends OnboardingEvent {
  final QuestionEntity question;
  final String answer;
  SelectAnswerEvent({required this.question, required this.answer});
}

class NextQuestionEvent extends OnboardingEvent {}

class PreviousQuestionEvent extends OnboardingEvent {}

class SubmitPreferencesEvent extends OnboardingEvent {}
