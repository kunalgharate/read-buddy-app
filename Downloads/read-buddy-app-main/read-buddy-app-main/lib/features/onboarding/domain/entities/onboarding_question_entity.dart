// domain/entities/onboarding_question_entity.dart
class OnboardingQuestionEntity {
  final int id;
  final String question;
  final String type;
  final List<String> options;

  const OnboardingQuestionEntity({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
  });
}