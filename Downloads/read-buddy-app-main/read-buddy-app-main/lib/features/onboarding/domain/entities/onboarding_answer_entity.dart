// onboarding_answer_entity.dart
class OnboardingAnswerEntity {
  final int questionId;
  final List<String> selectedOptions; // always a list, single_select = 1 item

  const OnboardingAnswerEntity({
    required this.questionId,
    required this.selectedOptions,
  });
}