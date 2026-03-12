// onboarding_question_model.dart
import '../../domain/entities/onboarding_question_entity.dart';

class OnboardingQuestionModel extends OnboardingQuestionEntity {
  const OnboardingQuestionModel({
    required super.id,
    required super.question,
    required super.type,
    required super.options,
  });

  factory OnboardingQuestionModel.fromJson(Map<String, dynamic> json) {
    return OnboardingQuestionModel(
      id: json['id'],
      question: json['question'],
      type: json['type'],
      options: List<String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'type': type,
    'options': options,
  };
}