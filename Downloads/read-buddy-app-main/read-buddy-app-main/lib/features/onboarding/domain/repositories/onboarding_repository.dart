// domain/repositories/onboarding_repository.dart
import '../entities/onboarding_question_entity.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingQuestionEntity>> getQuestions();
}