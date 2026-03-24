// domain/repositories/onboarding_repository.dart
import '../entity/onboarding_question_entity.dart';

abstract class OnboardingRepository {
  Future<List<QuestionEntity>> getQuestions();
  Future<void> setPreferences(Map<String, dynamic> preferences);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
  Future<void> deletePreferences();
  Future<void> setOnboardingStatus();
}